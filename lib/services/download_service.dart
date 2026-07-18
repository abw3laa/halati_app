import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/download_item.dart';
import 'media_store_service.dart';
import 'status_service.dart';

/// Downloads a *direct* media URL (one that already points at an .mp4 /
/// .jpg / .mp3 file, e.g. a CDN link) and stores it under Halati's own
/// download folders, sorted by kind — matching the "تحميلاتي" screen.
class DownloadService {
  DownloadService._();
  static final instance = DownloadService._();

  final Dio _dio = Dio();

  DownloadKind kindForUrl(String url) {
    final lower = url.toLowerCase();
    // فحص ذكي يحتوي على الصيغة حتى لو كان هناك معلمات استعلام (Query Parameters) بعدها
    if (lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.webm')) {
      return DownloadKind.video;
    }
    if (lower.contains('.mp3') ||
        lower.contains('.m4a') ||
        lower.contains('.wav')) {
      return DownloadKind.music;
    }
    return DownloadKind.image;
  }

  String _subfolder(DownloadKind kind) => switch (kind) {
        DownloadKind.video => 'video',
        DownloadKind.image => 'images',
        DownloadKind.music => 'music',
      };

  bool looksLikeDirectMediaUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) return false;

    // تعديل مهم: نقبل أي رابط صحيح يبدأ بـ http أو https لضمان عمل روابط الـ CDN المستخرجة من السيرفر
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  /// Downloads [url] to disk, reporting 0.0–1.0 progress via [onProgress].
  ///
  /// [knownExt] / [knownKind] should be passed whenever the caller already
  /// knows the real media type from elsewhere (e.g. the extraction
  /// server's response `ext` field) — CDN links returned by yt-dlp are
  /// long, signed, tokenized URLs (`...googlevideo.com/videoplayback?
  /// expire=...&mime=video%2Fmp4...`) that very often contain **no**
  /// `.mp4`/`.jpg` substring at all, so guessing the kind from the URL
  /// text alone (via [kindForUrl]) silently misfiles real videos into the
  /// images folder with a `.jpg`-ish fallback name — they "download
  /// successfully" but then can't be opened and don't show up as a video
  /// anywhere. Falls back to the old URL-sniffing heuristic only when
  /// neither is supplied, e.g. for a raw direct link the user pasted
  /// themselves that already has a real extension in its path.
  Future<File> download(
    String url, {
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
    String? knownExt,
    DownloadKind? knownKind,
  }) async {
    final kind = knownKind ?? _kindForExtOrUrl(knownExt, url);
    final dir = await StatusService.instance.downloadsDir(_subfolder(kind));

    final ext = (knownExt != null && knownExt.isNotEmpty)
        ? knownExt
        : _extensionFromUrl(url) ??
            switch (kind) {
              DownloadKind.video => 'mp4',
              DownloadKind.music => 'mp3',
              DownloadKind.image => 'jpg',
            };

    final fileName = 'halati_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final savePath = '${dir.path}/$fileName';

    await _dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );

    // Also publish a copy into the public MediaStore collection matching
    // [kind], so the file actually shows up in the phone's Gallery
    // (video/image) or file manager Download folder (everything else) —
    // not just inside Halati's own private "تحميلاتي" list. Best-effort:
    // the download itself has already succeeded and is fully usable from
    // within the app either way if this secondary publish step fails.
    unawaited(MediaStoreService.instance.publish(
      sourcePath: savePath,
      displayName: fileName,
      kind: kind,
    ));

    return File(savePath);
  }

  /// Best-effort extension sniff straight from the URL's path segment
  /// (works for plain direct-media links; returns null for tokenized CDN
  /// URLs with no real extension in the visible path).
  String? _extensionFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return null;
    final lastSegment = uri.pathSegments.last.split('?').first;
    final dotIndex = lastSegment.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == lastSegment.length - 1) return null;
    return lastSegment.substring(dotIndex + 1).toLowerCase();
  }

  DownloadKind _kindForExtOrUrl(String? knownExt, String url) {
    if (knownExt != null && knownExt.isNotEmpty) {
      return _kindForExt(knownExt);
    }
    return kindForUrl(url);
  }

  DownloadKind _kindForExt(String ext) {
    final lower = ext.toLowerCase();
    if (['mp4', 'mov', 'webm', 'mkv', '3gp'].contains(lower)) {
      return DownloadKind.video;
    }
    if (['mp3', 'm4a', 'wav', 'aac', 'ogg'].contains(lower)) {
      return DownloadKind.music;
    }
    return DownloadKind.image;
  }

  Future<List<DownloadItem>> listDownloads(DownloadKind kind) async {
    final dir = await StatusService.instance.downloadsDir(_subfolder(kind));
    final items = <DownloadItem>[];
    if (!await dir.exists()) return items;
    await for (final entity in dir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        items.add(DownloadItem(
          path: entity.path,
          name: entity.uri.pathSegments.last,
          sizeBytes: stat.size,
          modified: stat.modified,
          kind: kind,
        ));
      }
    }
    items.sort((a, b) => b.modified.compareTo(a.modified));
    return items;
  }

  Future<void> deleteDownload(DownloadItem item) async {
    final file = File(item.path);
    if (await file.exists()) await file.delete();
  }
}
