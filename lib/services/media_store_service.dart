import 'package:flutter/services.dart';

import '../models/download_item.dart';

/// Talks to the small native Kotlin handler in `MainActivity.kt` that
/// inserts a file into Android's public MediaStore collections, so:
///   - saved/downloaded **videos** show up in the phone's Gallery app
///     (and any "Studio"-style video app) under Movies/Halati,
///   - saved/downloaded **images** show up in Gallery under
///     Pictures/Halati,
///   - everything else (music, etc.) lands in Download/Halati, visible in
///     any normal file manager exactly like a browser download would be.
///
/// Without this, files saved into the app's private external-files
/// directory are invisible everywhere except inside Halati itself — which
/// is exactly why downloads previously "succeeded" but never appeared in
/// the gallery or in a file manager's Download folder.
class MediaStoreService {
  MediaStoreService._();
  static final instance = MediaStoreService._();

  static const _channel = MethodChannel('com.abwaalaa.halati/media_store');

  /// Copies the file at [sourcePath] into the appropriate public
  /// MediaStore collection for [kind], returning the resulting
  /// `content://` URI (or a plain file path on very old Android
  /// versions). Returns null if the platform call fails for any reason —
  /// callers should treat that as non-fatal, since the file still exists
  /// at [sourcePath] inside the app either way.
  Future<String?> publish({
    required String sourcePath,
    required String displayName,
    required DownloadKind kind,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'saveToPublicStorage',
        {
          'sourcePath': sourcePath,
          'displayName': displayName,
          'mimeType': _mimeTypeFor(kind, displayName),
          'collection': switch (kind) {
            DownloadKind.video => 'video',
            DownloadKind.image => 'image',
            DownloadKind.music => 'downloads',
          },
        },
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  String _mimeTypeFor(DownloadKind kind, String displayName) {
    final ext = displayName.split('.').last.toLowerCase();
    return switch (kind) {
      DownloadKind.video => switch (ext) {
          'webm' => 'video/webm',
          'mov' => 'video/quicktime',
          _ => 'video/mp4',
        },
      DownloadKind.image => switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        },
      DownloadKind.music => switch (ext) {
          'wav' => 'audio/wav',
          'ogg' => 'audio/ogg',
          'm4a' => 'audio/mp4',
          _ => 'audio/mpeg',
        },
    };
  }
}
