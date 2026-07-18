import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../l10n/app_localization.dart';
import '../models/status_item.dart';
import '../services/status_service.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StatusItem> items;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _index;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  bool _showToast = false;

  static const _imageDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _progressController = AnimationController(vsync: this);
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _next();
    });
    _loadCurrent();
  }

  StatusItem get _current => widget.items[_index];

  void _loadCurrent() {
    _videoController?.dispose();
    _videoController = null;
    _progressController
      ..reset()
      ..stop();

    if (_current.type == StatusMediaType.video) {
      final controller = VideoPlayerController.file(File(_current.path));
      _videoController = controller;
      controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controller.play();
        _progressController.duration = controller.value.duration;
        _progressController.forward();
      });
    } else {
      _progressController.duration = _imageDuration;
      _progressController.forward();
    }
  }

  void _next() {
    if (_index < widget.items.length - 1) {
      setState(() => _index++);
      _loadCurrent();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() => _index--);
      _loadCurrent();
    }
  }

  void _pause() {
    if (_videoController?.value.isPlaying ?? false) {
      _videoController!.pause();
      _progressController.stop();
    } else {
      _videoController?.play();
      _progressController.forward();
    }
  }

  Future<void> _save() async {
    try {
      await StatusService.instance.saveStatus(_current);
      setState(() => _showToast = true);
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showToast = false);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(),
          // Top gradient overlay + progress + user info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: List.generate(widget.items.length, (i) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (_, __) {
                                double value = 0;
                                if (i < _index) {
                                  value = 1;
                                } else if (i == _index) {
                                  value = _progressController.value;
                                }
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _current.type == StatusMediaType.video
                              ? Icons.movie_outlined
                              : Icons.image_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Text(_relativeTime(_current.postedAt),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              if (_current.deletedByOwner) ...[
                                const SizedBox(width: 6),
                                const Text('🚫',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _save,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999)),
                          ),
                          icon: const Icon(Icons.cloud_download, size: 18),
                          label: Text(T(context, 'save')),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tap zones
          Row(
            children: [
              Expanded(child: GestureDetector(onTap: _prev, behavior: HitTestBehavior.translucent)),
              Expanded(
                flex: 2,
                child: GestureDetector(onTap: _pause, behavior: HitTestBehavior.translucent),
              ),
              Expanded(child: GestureDetector(onTap: _next, behavior: HitTestBehavior.translucent)),
            ],
          ),
          // Save toast
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            bottom: _showToast ? 40 : -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(T(context, 'saved'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    if (_current.type == StatusMediaType.video) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    return Image.file(File(_current.path), fit: BoxFit.cover);
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
