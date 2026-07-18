import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/update_manifest.dart';

/// Handles the whole out-of-Google-Play update flow:
///  1. Fetch a small JSON manifest from a URL you control (MediaFire itself
///     can't serve raw JSON reliably, so host `update.json` somewhere
///     simple instead — see UPDATE_SERVER_TEMPLATE.md — and only point its
///     `apkUrl` field at your MediaFire direct-download link).
///  2. Compare against the running app's version/build number.
///  3. Download the new APK into the app's cache dir with progress.
///  4. Ask for the "install unknown apps" permission if needed, then hand
///     the file to the system installer via a FileProvider content:// URI.
class UpdateService {
  UpdateService._();
  static final instance = UpdateService._();

  /// Replace with wherever you end up hosting `update.json`
  /// (GitHub raw file, GitHub Gist "raw" link, your own server, Firebase
  /// Hosting, etc. — anywhere that returns the file as plain JSON over
  /// HTTPS with no login wall works). This is intentionally *not* the
  /// MediaFire link itself: MediaFire is used only for the APK binary,
  /// referenced from inside this manifest via `apkUrl`.
  static const String manifestUrl =
      'https://raw.githubusercontent.com/abw3laa/halati_updates/main/update.json';

  static const _kLastCheckKey = 'update_service.last_check_millis';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<PackageInfo> get _packageInfo => PackageInfo.fromPlatform();

  /// Fetches the manifest and compares it with the installed app.
  /// Returns `null` on any network/parse failure so callers can fail
  /// silently on a background check instead of surfacing a scary error.
  Future<UpdateCheckResult?> checkForUpdate({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!force) {
        // Avoid hammering the manifest URL — at most once every 6 hours
        // for automatic background checks triggered from app start.
        final lastCheck = prefs.getInt(_kLastCheckKey);
        if (lastCheck != null) {
          final elapsed = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(lastCheck));
          if (elapsed < const Duration(hours: 6)) return null;
        }
      }

      final response = await _dio.get<String>(
        manifestUrl,
        options: Options(responseType: ResponseType.plain),
      );
      await prefs.setInt(_kLastCheckKey, DateTime.now().millisecondsSinceEpoch);

      final data = response.data;
      if (data == null || data.isEmpty) return null;

      final manifest = UpdateManifest.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
      if (manifest.apkUrl.isEmpty) return null;

      final info = await _packageInfo;
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final isNewer = manifest.latestBuildNumber > currentBuild;
      final isMandatory = manifest.minRequiredBuildNumber != null &&
          currentBuild < manifest.minRequiredBuildNumber!;

      return UpdateCheckResult(
        manifest: manifest,
        isUpdateAvailable: isNewer,
        isMandatory: isMandatory,
        currentBuildNumber: currentBuild,
      );
    } catch (_) {
      // Network hiccup, malformed manifest, DNS failure, etc. — treated
      // as "no update available right now", never blocks app usage.
      return null;
    }
  }

  /// Downloads the APK referenced by [manifest] to a cache file,
  /// reporting 0.0–1.0 progress. Re-uses a previously completed download
  /// if one already exists for the same version.
  Future<File> downloadApk(
    UpdateManifest manifest, {
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/halati_update_${manifest.latestVersion}.apk';
    final file = File(savePath);

    if (await file.exists()) {
      final size = await file.length();
      if (size > 0) {
        onProgress(1.0);
        return file;
      }
    }

    await _dio.download(
      manifest.apkUrl,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    return file;
  }

  /// Requests the "install unknown apps" permission (Android 8+) and, once
  /// granted, opens the downloaded APK with the system package installer.
  Future<InstallApkResult> installApk(File apkFile) async {
    if (Platform.isAndroid) {
      final status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        final result = await Permission.requestInstallPackages.request();
        if (!result.isGranted) {
          return InstallApkResult.permissionDenied;
        }
      }
    }

    final result = await OpenFilex.open(apkFile.path);
    return result.type == ResultType.done
        ? InstallApkResult.launched
        : InstallApkResult.failed;
  }
}

enum InstallApkResult { launched, permissionDenied, failed }
