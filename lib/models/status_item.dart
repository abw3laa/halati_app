enum StatusMediaType { image, video }

/// A single WhatsApp status, whether still live in WhatsApp's own
/// `.Statuses` cache or kept alive by Halati after the sender deleted it
/// early (see [deletedByOwner]).
class StatusItem {
  /// Stable identity used to match the same status across refreshes and
  /// across the live-folder scan vs. Halati's own retention cache.
  /// Built from the *original* file name (WhatsApp reuses predictable
  /// names per status slot) rather than the full path, so it still
  /// matches after the source file is gone.
  final String id;

  /// Path to the file Halati should actually render:
  ///  - while the status is still live, this is the original WhatsApp
  ///    cache file path (or a SAF content:// URI);
  ///  - once the sender deletes it early, this instead points at the
  ///    private "keep-alive" copy Halati silently made the first time it
  ///    saw the status, so the media can still be displayed.
  final String path;
  final String? contentUri;
  final StatusMediaType type;

  /// When WhatsApp originally posted the status. This is what the 24-hour
  /// countdown is measured against, *not* the time Halati happened to
  /// scan it — so a status keeps exactly the same lifetime it would have
  /// had inside WhatsApp itself, deleted-early or not.
  final DateTime postedAt;

  final bool viewed;

  /// True once the status has disappeared from WhatsApp's live
  /// `.Statuses` folder before its natural 24h lifetime ended — i.e. the
  /// sender deleted it early. Halati keeps showing it (from the
  /// keep-alive copy) with a 🚫 marker until [postedAt] + 24h.
  final bool deletedByOwner;

  const StatusItem({
    required this.id,
    required this.path,
    this.contentUri,
    required this.type,
    required this.postedAt,
    this.viewed = false,
    this.deletedByOwner = false,
  });

  /// Time remaining until this status would have expired naturally inside
  /// WhatsApp (24h after [postedAt]), regardless of early deletion.
  Duration get remaining {
    final expiry = postedAt.add(const Duration(hours: 24));
    final left = expiry.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Whether the 24h WhatsApp lifetime has fully elapsed — at this point
  /// Halati should stop showing the status even if it kept a copy.
  bool get isExpired => remaining == Duration.zero;

  StatusItem copyWith({
    String? path,
    bool? viewed,
    bool? deletedByOwner,
  }) =>
      StatusItem(
        id: id,
        path: path ?? this.path,
        contentUri: contentUri,
        type: type,
        postedAt: postedAt,
        viewed: viewed ?? this.viewed,
        deletedByOwner: deletedByOwner ?? this.deletedByOwner,
      );
}
