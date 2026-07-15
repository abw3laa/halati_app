import 'dart:io';

import 'package:dio/dio.dart';

import '../models/download_item.dart';
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
  Future<File> download(
    String url, {
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final kind = kindForUrl(url);
    final dir = await StatusService.instance.downloadsDir(_subfolder(kind));

    // استخراج اسم الملف بشكل آمن وتجنب مشاكل المعلمات الطويلة في روابط الـ CDN
    String fileName = 'halati_${DateTime.now().millisecondsSinceEpoch}';
    final uri = Uri.tryParse(url);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final lastSegment = uri.pathSegments.last;
      if (lastSegment.contains('.')) {
        // نأخذ الجزء الأول قبل أي علامات استفهام أو معلمات
        fileName = lastSegment.split('?').first;
      } else {
        // إضافة امتداد افتراضي بناءً على النوع إذا لم نجد صيغة واضحة في الرابط
        final ext = kind == DownloadKind.video
            ? 'mp4'
            : (kind == DownloadKind.music ? 'mp3' : 'jpg');
        fileName = '$fileName.$ext';
      }
    }

    final savePath = '${dir.path}/$fileName';

    await _dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    return File(savePath);
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
