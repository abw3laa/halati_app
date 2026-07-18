import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

import '../models/status_item.dart';
import 'media_store_service.dart';
import '../models/download_item.dart' show DownloadKind;

/// Common on-device locations for the WhatsApp / WhatsApp Business
/// ".Statuses" cache folder across Android versions & OEM WhatsApp forks.
const _kLegacyStatusDirs = [
  '/storage/emulated/0/WhatsApp/Media/.Statuses',
  '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
  '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
];

const _kRetentionPrefsKey = 'status_service.retention_cache';

/// Handles three responsibilities:
///  1. Reading the live status cache (read-only, cleared by WhatsApp
///     itself roughly 24h after each status is posted — or sooner, if the
///     sender deletes it manually).
///  2. Silently keeping a private copy of every status Halati has seen,
///     so that if the sender deletes it early, Halati can keep showing it
///     (marked with 🚫) for the *rest* of its original 24h lifetime —
///     exactly like WhatsApp itself would have, had it not been deleted.
///  3. Saving a chosen status permanently into Halati's own downloads
///     folder when the user explicitly taps "save".
class StatusService {
  StatusService._();
  static final instance = StatusService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _prefsInstance async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Folder inside app-external-storage where saved statuses & downloads
  /// live, mirroring the `storage/emulated/0/halati/download` path shown
  /// in the design mock-ups.
  Future<Directory> savedStatusesDir() async {
    final base = await getExternalStorageDirectory();
    final dir = Directory('${base!.path}/halati/download/statuses');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> downloadsDir(String subfolder) async {
    final base = await getExternalStorageDirectory();
    final dir = Directory('${base!.path}/halati/download/$subfolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Private cache folder (not shown in "My downloads") that silently
  /// holds a copy of every *currently live* status, purely so it can
  /// still be rendered if the sender deletes the original before its 24h
  /// lifetime is up. Cleared automatically as entries expire.
  Future<Directory> _keepAliveDir() async {
    final base = await getExternalStorageDirectory();
    final dir = Directory('${base!.path}/halati/.keep_alive');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Requests the classic storage permission (works on Android <= 10, and
  /// is still useful for media read on newer versions via granular media
  /// permissions).
  Future<bool> requestLegacyPermission() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final storage = await Permission.storage.request();
      return photos.isGranted || videos.isGranted || storage.isGranted;
    }
    return true;
  }

  /// Opens the Storage Access Framework folder picker so the user can grant
  /// persistent access to WhatsApp's `.Statuses` folder. Required on
  /// Android 11+ due to scoped storage. Returns the persisted tree URI
  /// (store it via [SettingsService.setStatusTreeUri]) or null if cancelled.
  Future<String?> pickStatusFolder() async {
    final uri = await saf.openDocumentTree(
      grantWritePermission: false,
      persistablePermission: true,
    );
    return uri?.toString();
  }

  // ── Retention cache (persisted as small JSON in SharedPreferences) ──────
  //
  // Keyed by the stable status [StatusItem.id]. Each entry remembers when
  // Halati first saw the status (used as the 24h anchor) and the path to
  // the private keep-alive copy, so a status can keep rendering — with a
  // 🚫 marker — even after WhatsApp's own file is gone.

  Future<Map<String, _RetentionEntry>> _loadCache() async {
    final prefs = await _prefsInstance;
    final raw = prefs.getString(_kRetentionPrefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, _RetentionEntry.fromJson(value)),
      );
    } catch (e) {
      debugPrint('Retention cache decode failed: $e');
      return {};
    }
  }

  Future<void> _saveCache(Map<String, _RetentionEntry> cache) async {
    final prefs = await _prefsInstance;
    final encoded = jsonEncode(cache.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_kRetentionPrefsKey, encoded);
  }

  /// Builds a stable identity for a status independent of its full path,
  /// so the same status keeps matching across refreshes even once the
  /// original file has been removed by WhatsApp.
  String _stableId(String fileName, StatusMediaType type) =>
      '${type.name}_$fileName';

  /// Tries direct filesystem access first (older Android / rooted access),
  /// then falls back to the persisted SAF tree URI chosen via
  /// [pickStatusFolder]. The result is merged with Halati's retention
  /// cache so that:
  ///   • statuses deleted early by their sender keep appearing (🚫) until
  ///     24h after they were first posted, and
  ///   • anything past that 24h mark is dropped for good, matching
  ///     WhatsApp's own status lifetime exactly.
  Future<List<StatusItem>> loadLiveStatuses({String? treeUri}) async {
    final live = <StatusItem>[];

    // 1) Legacy direct path (Android 10 and below, or MANAGE_EXTERNAL_STORAGE).
    for (final path in _kLegacyStatusDirs) {
      final dir = Directory(path);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            final item = _fileToStatusItem(entity);
            if (item != null) live.add(item);
          }
        }
      }
    }

    // 2) SAF fallback (Android 11+ scoped storage) — only tried when the
    // legacy scan found nothing, mirroring the previous behaviour.
    if (live.isEmpty && treeUri != null) {
      try {
        final uri = Uri.parse(treeUri);
        await for (final doc in saf.listFiles(uri, columns: const [
          saf.DocumentFileColumn.id,
          saf.DocumentFileColumn.displayName,
          saf.DocumentFileColumn.size,
          saf.DocumentFileColumn.lastModified,
          saf.DocumentFileColumn.mimeType,
        ])) {
          final name = doc.name ?? '';
          final mime = doc.type ?? '';
          final isVideo = mime.startsWith('video/') || name.endsWith('.mp4');
          final isImage = mime.startsWith('image/') ||
              name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.png') ||
              name.endsWith('.webp');
          if (!isVideo && !isImage) continue;
          final type = isVideo ? StatusMediaType.video : StatusMediaType.image;
          live.add(StatusItem(
            id: _stableId(name, type),
            path: doc.uri.toString(),
            contentUri: doc.uri.toString(),
            type: type,
            postedAt: doc.lastModified ?? DateTime.now(),
          ));
        }
      } catch (e) {
        debugPrint('SAF status listing failed: $e');
      }
    }

    return _mergeWithRetentionCache(live);
  }

  /// Core of requirement #4: reconciles the freshly-scanned live statuses
  /// with everything Halati remembers seeing before.
  ///
  ///  • Still present live            → shown normally, cache refreshed.
  ///  • In cache but missing live     → sender deleted it early; keep
  ///                                    showing it (🚫) from the private
  ///                                    keep-alive copy, as long as it's
  ///                                    within 24h of [StatusItem.postedAt].
  ///  • Past the 24h mark either way  → dropped, cache entry purged.
  Future<List<StatusItem>> _mergeWithRetentionCache(
    List<StatusItem> live,
  ) async {
    final cache = await _loadCache();
    final liveIds = {for (final item in live) item.id: item};
    final result = <StatusItem>[];
    final nextCache = <String, _RetentionEntry>{};

    // Statuses still visible in WhatsApp's own folder.
    for (final item in live) {
      final existing = cache[item.id];
      final postedAt = existing?.postedAt ?? item.modifiedFallback;
      final resolved = item.withPostedAt(postedAt);
      if (resolved.isExpired) continue; // safety net; shouldn't normally hit

      // Refresh (or create) the private keep-alive copy while the source
      // file is still readable, so it survives the status being deleted
      // early later on.
      final keepAlivePath =
          existing?.keepAlivePath ?? await _tryMakeKeepAliveCopy(resolved);

      // Widgets (Image.file / VideoPlayerController.file) only understand
      // real filesystem paths, not content:// SAF URIs — so whenever the
      // item came from the SAF folder picker, always render from the
      // materialized keep-alive copy instead of the raw content:// path.
      // This is also what makes the very first "grant access" refresh
      // actually show thumbnails, not just later ones after deletion.
      final renderable = resolved.contentUri != null && keepAlivePath != null
          ? resolved.copyWith(path: keepAlivePath)
          : resolved;

      result.add(renderable.copyWith(viewed: existing?.viewed ?? false));
      nextCache[item.id] = _RetentionEntry(
        postedAt: postedAt,
        keepAlivePath: keepAlivePath,
        viewed: existing?.viewed ?? false,
      );
    }

    // Statuses the sender deleted before Halati's next refresh.
    for (final entry in cache.entries) {
      if (liveIds.containsKey(entry.key)) continue; // handled above
      final cached = entry.value;
      if (cached.isExpired) continue; // 24h is up — drop for good

      if (cached.keepAlivePath == null ||
          !File(cached.keepAlivePath!).existsSync()) {
        // No usable copy was ever made (e.g. app was killed before the
        // first refresh could cache it) — nothing to show, drop quietly.
        continue;
      }

      result.add(StatusItem(
        id: entry.key,
        path: cached.keepAlivePath!,
        type: cached.keepAlivePath!.toLowerCase().endsWith('.mp4')
            ? StatusMediaType.video
            : StatusMediaType.image,
        postedAt: cached.postedAt,
        viewed: cached.viewed,
        deletedByOwner: true,
      ));
      nextCache[entry.key] = cached;
    }

    await _saveCache(nextCache);
    result.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return result;
  }

  /// Marks a status as viewed in the retention cache (so re-opening the
  /// app remembers it was already seen).
  Future<void> markViewed(StatusItem item) async {
    final cache = await _loadCache();
    final existing = cache[item.id];
    if (existing == null) return;
    cache[item.id] = existing.copyWith(viewed: true);
    await _saveCache(cache);
  }

  /// Best-effort silent copy so a status can still be shown after the
  /// sender deletes it early. Failures are non-fatal — the status simply
  /// won't survive early deletion if the copy couldn't be made in time.
  Future<String?> _tryMakeKeepAliveCopy(StatusItem item) async {
    try {
      final dir = await _keepAliveDir();
      final ext = item.type == StatusMediaType.video ? 'mp4' : 'jpg';
      final destPath = '${dir.path}/${item.id}.$ext';
      final dest = File(destPath);
      if (await dest.exists()) return destPath; // already cached

      if (item.contentUri != null) {
        final bytes = await saf.getDocumentContent(Uri.parse(item.contentUri!));
        if (bytes == null) return null;
        await dest.writeAsBytes(bytes);
      } else {
        await File(item.path).copy(destPath);
      }
      return destPath;
    } catch (e) {
      debugPrint('Keep-alive copy failed for ${item.id}: $e');
      return null;
    }
  }

  StatusItem? _fileToStatusItem(File file) {
    final name = file.path.toLowerCase();
    StatusMediaType? type;
    if (name.endsWith('.mp4')) {
      type = StatusMediaType.video;
    } else if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp')) {
      type = StatusMediaType.image;
    }
    if (type == null) return null;
    // WhatsApp drops a non-media placeholder in this folder; skip it.
    if (name.contains('.nomedia')) return null;

    final fileName = file.uri.pathSegments.last;
    return StatusItem(
      id: _stableId(fileName, type),
      path: file.path,
      type: type,
      postedAt: file.statSync().modified,
    );
  }

  /// Copies a status (from either a direct file path, a SAF content URI,
  /// or Halati's own keep-alive copy) into Halati's permanent
  /// user-facing saved-statuses folder.
  Future<File> saveStatus(StatusItem item) async {
    final dir = await savedStatusesDir();
    final ext = item.type == StatusMediaType.video ? 'mp4' : 'jpg';
    final destPath =
        '${dir.path}/status_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // `item.path` is preferred whenever it already points at a real,
    // materialized file (Halati's own keep-alive copy, or a legacy direct
    // path) — only fall back to re-reading the raw SAF content:// URI if
    // no local copy exists yet, since that URI can stop resolving the
    // moment the sender deletes the original status.
    final localFile = File(item.path);
    if (await localFile.exists()) {
      final saved = await localFile.copy(destPath);
      unawaited(MediaStoreService.instance.publish(
        sourcePath: saved.path,
        displayName: saved.uri.pathSegments.last,
        kind: item.type == StatusMediaType.video
            ? DownloadKind.video
            : DownloadKind.image,
      ));
      return saved;
    }

    if (item.contentUri != null) {
      final bytes = await saf.getDocumentContent(Uri.parse(item.contentUri!));
      if (bytes == null) {
        throw Exception('تعذر قراءة محتوى الحالة');
      }
      final file = File(destPath);
      await file.writeAsBytes(bytes);
      unawaited(MediaStoreService.instance.publish(
        sourcePath: file.path,
        displayName: file.uri.pathSegments.last,
        kind: item.type == StatusMediaType.video
            ? DownloadKind.video
            : DownloadKind.image,
      ));
      return file;
    }

    throw Exception('تعذر العثور على ملف الحالة');
  }
}

/// Internal bookkeeping record persisted per status in SharedPreferences.
class _RetentionEntry {
  final DateTime postedAt;
  final String? keepAlivePath;
  final bool viewed;

  const _RetentionEntry({
    required this.postedAt,
    required this.keepAlivePath,
    this.viewed = false,
  });

  bool get isExpired =>
      DateTime.now().difference(postedAt) >= const Duration(hours: 24);

  _RetentionEntry copyWith({bool? viewed}) => _RetentionEntry(
        postedAt: postedAt,
        keepAlivePath: keepAlivePath,
        viewed: viewed ?? this.viewed,
      );

  Map<String, dynamic> toJson() => {
        'postedAt': postedAt.toIso8601String(),
        'keepAlivePath': keepAlivePath,
        'viewed': viewed,
      };

  factory _RetentionEntry.fromJson(Map<String, dynamic> json) =>
      _RetentionEntry(
        postedAt: DateTime.parse(json['postedAt'] as String),
        keepAlivePath: json['keepAlivePath'] as String?,
        viewed: json['viewed'] as bool? ?? false,
      );
}

extension _StatusItemHelpers on StatusItem {
  /// Falls back to the file's own modified time the first time a status
  /// is ever seen (before it has a cache entry to read [postedAt] from).
  DateTime get modifiedFallback => postedAt;

  StatusItem withPostedAt(DateTime postedAt) => StatusItem(
        id: id,
        path: path,
        contentUri: contentUri,
        type: type,
        postedAt: postedAt,
        viewed: viewed,
        deletedByOwner: deletedByOwner,
      );
}
