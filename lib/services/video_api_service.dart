import 'package:dio/dio.dart';

/// Talks to *your own* external extraction API (the FastAPI server built
/// alongside this file) to turn a TikTok / Instagram / Facebook / YouTube
/// page link into a clean, direct, no-watermark media URL that the
/// existing on-device [DownloadService] can then download as-is.
///
/// This file is self-contained on purpose: it doesn't touch any other
/// service, it just exposes one function to call from the UI layer.
class VideoApiService {
  VideoApiService._();
  static final instance = VideoApiService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// True when [pageUrl] is a YouTube link — this is the only platform
  /// where the download screen offers a video/audio choice, since
  /// TikTok/Instagram/Facebook status-style clips are always short
  /// videos in practice.
  static bool isYouTubeUrl(String pageUrl) {
    final lower = pageUrl.toLowerCase();
    return lower.contains('youtube.com') || lower.contains('youtu.be');
  }

  /// Base URL of your extraction server.
  ///
  /// - While testing locally with an Android *emulator*, use
  ///   `http://10.0.2.2:8000` (the emulator's alias for the host machine's
  ///   localhost).
  /// - On a *physical device* on the same Wi-Fi, use your PC's LAN IP,
  ///   e.g. `http://192.168.1.10:8000`.
  /// - In production, point this at your deployed server's HTTPS domain.
  static const String baseUrl = 'https://halati-extract-server.onrender.com';

  /// Sends [pageUrl] (a TikTok/Instagram/Facebook/YouTube link) to the
  /// `/extract` endpoint and returns the direct, watermark-free media URL.
  ///
  /// [wantAudio] only has an effect for YouTube links — it asks the server
  /// to return the best audio-only stream instead of video. Every other
  /// platform ignores it server-side and always extracts video, since
  /// TikTok/Instagram/Facebook clips are only ever downloaded as video in
  /// this app.
  ///
  /// Throws a [VideoApiException] with a user-facing message on failure.
  Future<ExtractedMedia> extract(String pageUrl, {bool wantAudio = false}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/extract',
        data: {
          'url': pageUrl,
          'format': wantAudio ? 'audio' : 'video',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final directUrl = data['direct_url'] as String?;
      if (directUrl == null || directUrl.isEmpty) {
        throw const VideoApiException(
            'لم يتمكن السيرفر من استخراج رابط الفيديو');
      }

      return ExtractedMedia(
        directUrl: directUrl,
        title: data['title'] as String? ?? 'video',
        ext: data['ext'] as String? ?? 'mp4',
        platform: data['platform'] as String? ?? 'unknown',
        hasWatermark: data['has_watermark'] as bool? ?? false,
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? (e.response?.data as Map)['detail']?.toString()
          : null;
      throw VideoApiException(
          serverMessage ?? 'تعذر الاتصال بسيرفر الاستخراج: ${e.message}');
    }
  }
}

class ExtractedMedia {
  final String directUrl;
  final String title;
  final String ext;
  final String platform;
  final bool hasWatermark;

  const ExtractedMedia({
    required this.directUrl,
    required this.title,
    required this.ext,
    required this.platform,
    required this.hasWatermark,
  });
}

class VideoApiException implements Exception {
  final String message;
  const VideoApiException(this.message);

  @override
  String toString() => message;
}
