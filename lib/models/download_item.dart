enum DownloadKind { video, image, music }

class DownloadItem {
  final String path;
  final String name;
  final int sizeBytes;
  final DateTime modified;
  final DownloadKind kind;

  const DownloadItem({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.modified,
    required this.kind,
  });

  String get sizeLabel {
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}
