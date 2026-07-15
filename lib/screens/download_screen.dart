import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localization.dart';
import '../services/download_service.dart';
import '../services/video_api_service.dart';
import 'downloads_screen.dart';

enum _Format { video, audio, image }

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final _controller = TextEditingController();
  _Format _format = _Format.video;
  double? _progress;
  CancelToken? _cancelToken;
  String? _error;
  bool _resolving = false; // true while VideoApiService is extracting the link

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _controller.text = data!.text!);
    }
  }

  Future<void> _startDownload() async {
    final pastedUrl = _controller.text.trim();
    if (pastedUrl.isEmpty) {
      setState(() => _error = T(context, 'invalid_link'));
      return;
    }

    setState(() => _error = null);

    // Resolve the actual file URL to hand to the on-device downloader:
    //  - If the user already pasted a direct media link (.mp4/.jpg/...),
    //    use it as-is, exactly like before.
    //  - Otherwise (a TikTok/Instagram/Facebook/YouTube page link), call
    //    our external extraction API first to get the clean, no-watermark
    //    direct URL, then continue with the same download flow.
    String downloadUrl;
    if (DownloadService.instance.looksLikeDirectMediaUrl(pastedUrl)) {
      downloadUrl = pastedUrl;
    } else {
      setState(() => _resolving = true);
      try {
        final extracted = await VideoApiService.instance.extract(pastedUrl);
        downloadUrl = extracted.directUrl;
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _resolving = false;
          _error = '$e';
        });
        return;
      }
      if (!mounted) return;
      setState(() => _resolving = false);
    }

    setState(() {
      _progress = 0;
      _cancelToken = CancelToken();
    });
    try {
      await DownloadService.instance.download(
        downloadUrl,
        cancelToken: _cancelToken,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      setState(() => _progress = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(T(context, 'saved'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = '$e';
      });
    }
  }

  void _cancel() {
    _cancelToken?.cancel();
    setState(() => _progress = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.cloud_download),
            const SizedBox(width: 8),
            Text(T(context, 'download_title')),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: T(context, 'link_hint'),
                          prefixIcon: const Icon(Icons.link),
                          filled: true,
                          fillColor: scheme.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                        onPressed: _paste, child: Text(T(context, 'paste'))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  T(context, 'direct_link_note'),
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: scheme.error)),
                ],
                const SizedBox(height: 20),
                Text(T(context, 'choose_format'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _formatButton(context, _Format.video, Icons.movie,
                          T(context, 'format_video')),
                      _formatButton(context, _Format.audio, Icons.music_note,
                          T(context, 'format_audio')),
                      _formatButton(context, _Format.image, Icons.image,
                          T(context, 'format_image')),
                    ],
                  ),
                ),
                if (_progress != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${T(context, 'downloading')} ${((_progress ?? 0) * 100).toStringAsFixed(0)}%'),
                            TextButton.icon(
                              onPressed: _cancel,
                              icon: Icon(Icons.close,
                                  size: 16, color: scheme.error),
                              label: Text(T(context, 'cancel'),
                                  style: TextStyle(color: scheme.error)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 10,
                            backgroundColor: scheme.surfaceContainerHighest,
                            color: scheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: (_progress == null && !_resolving)
                      ? _startDownload
                      : null,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  icon: _resolving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download),
                  label: Text(_resolving
                      ? T(context, 'downloading')
                      : T(context, 'download_now')),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  icon: const Icon(Icons.folder_open),
                  label: Text(T(context, 'my_downloads')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatButton(
      BuildContext context, _Format value, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    final active = _format == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _format = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? scheme.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4)
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: active ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: active ? scheme.primary : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
