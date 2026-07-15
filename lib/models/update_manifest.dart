/// Parsed representation of the small JSON manifest Halati polls to
/// discover new versions when distributed outside Google Play (e.g. a
/// direct-download link on MediaFire, GitHub Releases, or your own site).
///
/// Expected JSON shape (see `UPDATE_SERVER_TEMPLATE.md` for full docs):
/// ```json
/// {
///   "latestVersion": "2.1.0",
///   "latestBuildNumber": 5,
///   "apkUrl": "https://.../halati-2.1.0.apk",
///   "releaseNotes": { "ar": "...", "en": "...", "tr": "..." },
///   "minRequiredBuildNumber": 1,
///   "sha256": "optional file checksum"
/// }
/// ```
class UpdateManifest {
  final String latestVersion;
  final int latestBuildNumber;
  final String apkUrl;
  final Map<String, String> releaseNotes;

  /// If set, any installed build strictly below this number is considered
  /// unsafe to keep running (e.g. a critical fix) — lets you flag a
  /// mandatory update later without changing app code.
  final int? minRequiredBuildNumber;

  final String? sha256;

  const UpdateManifest({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.apkUrl,
    required this.releaseNotes,
    this.minRequiredBuildNumber,
    this.sha256,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    final notesRaw = json['releaseNotes'];
    final notes = <String, String>{};
    if (notesRaw is Map) {
      for (final entry in notesRaw.entries) {
        notes[entry.key.toString()] = entry.value.toString();
      }
    } else if (notesRaw is String) {
      // Allow a plain string for projects that don't want to localize notes.
      notes
        ..['ar'] = notesRaw
        ..['en'] = notesRaw
        ..['tr'] = notesRaw;
    }

    return UpdateManifest(
      latestVersion: json['latestVersion']?.toString() ?? '0.0.0',
      latestBuildNumber:
          int.tryParse(json['latestBuildNumber']?.toString() ?? '') ?? 0,
      apkUrl: json['apkUrl']?.toString() ?? '',
      releaseNotes: notes,
      minRequiredBuildNumber: json['minRequiredBuildNumber'] != null
          ? int.tryParse(json['minRequiredBuildNumber'].toString())
          : null,
      sha256: json['sha256']?.toString(),
    );
  }

  String notesFor(String languageCode) =>
      releaseNotes[languageCode] ?? releaseNotes['en'] ?? releaseNotes['ar'] ?? '';
}

/// Result of comparing a fetched [UpdateManifest] against the app that is
/// currently installed.
class UpdateCheckResult {
  final UpdateManifest manifest;
  final bool isUpdateAvailable;
  final bool isMandatory;
  final int currentBuildNumber;

  const UpdateCheckResult({
    required this.manifest,
    required this.isUpdateAvailable,
    required this.isMandatory,
    required this.currentBuildNumber,
  });
}
