import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localization.dart';
import '../models/status_item.dart';
import '../services/settings_service.dart';
import '../services/status_service.dart';
import '../theme/app_theme.dart';
import 'story_viewer_screen.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  List<StatusItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loading = true);

    await StatusService.instance.requestLegacyPermission();

    if (!mounted) return;
    final settings = context.read<SettingsService>();
    final items = await StatusService.instance.loadLiveStatuses(
      treeUri: settings.statusTreeUri,
    );

    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _grantAccess() async {
    final uri = await StatusService.instance.pickStatusFolder();
    if (uri == null) return;
    if (!mounted) return;
    await context.read<SettingsService>().setStatusTreeUri(uri);
    await _refresh();
  }

  Future<void> _saveStatus(StatusItem item) async {
    try {
      await StatusService.instance.saveStatus(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(T(context, 'saved'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.wifi_tethering, size: 26),
            const SizedBox(width: 8),
            Text(T(context, 'updates_title'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(child: _MyStatusTile()),
                  ),
                  if (_items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(onGrantAccess: _grantAccess),
                    )
                  else ...[
                    if (_items.any((e) => !e.viewed)) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Text(T(context, 'recent_updates'),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurfaceVariant)),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: _StatusGrid(
                          items: _items.where((e) => !e.viewed).toList(),
                          onOpen: _open,
                          onSave: _saveStatus,
                        ),
                      ),
                    ],
                    if (_items.any((e) => e.viewed)) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Text(T(context, 'viewed_updates'),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurfaceVariant)),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: _StatusGrid(
                          items: _items.where((e) => e.viewed).toList(),
                          onOpen: _open,
                          onSave: _saveStatus,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _open(StatusItem item) async {
    await StatusService.instance.markViewed(item);
    if (!mounted) return;
    setState(() {
      final idx = _items.indexWhere((e) => e.id == item.id);
      if (idx != -1) _items[idx] = _items[idx].copyWith(viewed: true);
    });
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          StoryViewerScreen(items: _items, initialIndex: _items.indexOf(item)),
    ));
  }
}

class _MyStatusTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.waGreenStart, AppColors.waGreenEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(T(context, 'my_status'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              Text(T(context, 'add_status'),
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGrantAccess;
  const _EmptyState({required this.onGrantAccess});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 48, color: scheme.outline),
          const SizedBox(height: 16),
          Text(
            T(context, 'no_statuses'),
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onGrantAccess,
            icon: const Icon(Icons.folder_open),
            label: Text(T(context, 'grant_access')),
          ),
        ],
      ),
    );
  }
}

/// Two-column grid of status thumbnails. Halati intentionally shows no
/// sender name here: WhatsApp's status media files carry no contact
/// association whatsoever, and there is no way to resolve one without
/// root-level access to WhatsApp's own private database (see
/// CONTACT_NAME_RESOLUTION.md for the full explanation of why this was a
/// deliberate product decision, not a missing feature).
class _StatusGrid extends StatelessWidget {
  final List<StatusItem> items;
  final ValueChanged<StatusItem> onOpen;
  final ValueChanged<StatusItem> onSave;

  const _StatusGrid(
      {required this.items, required this.onOpen, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => _StatusThumbnail(
          item: items[i],
          onOpen: () => onOpen(items[i]),
          onSave: () => onSave(items[i]),
        ),
        childCount: items.length,
      ),
    );
  }
}

class _StatusThumbnail extends StatelessWidget {
  final StatusItem item;
  final VoidCallback onOpen;
  final VoidCallback onSave;

  const _StatusThumbnail(
      {required this.item, required this.onOpen, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasFile = File(item.path).existsSync();

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasFile
                ? Image.file(File(item.path), fit: BoxFit.cover)
                : Container(
                    color: scheme.surfaceContainerHigh,
                    child: Icon(Icons.broken_image_outlined,
                        color: scheme.outline),
                  ),
            // Dim overlay for already-viewed items, matching the old
            // ring's viewed/unviewed distinction without needing a ring.
            if (item.viewed)
              Container(color: Colors.black.withValues(alpha: 0.28)),
            // Video indicator
            if (item.type == StatusMediaType.video)
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(Icons.play_circle_fill,
                    color: Colors.white, size: 28),
              ),
            // Deleted-by-owner marker — still shown until the real 24h
            // WhatsApp lifetime naturally ends.
            if (item.deletedByOwner)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🚫', style: TextStyle(fontSize: 12)),
                ),
              ),
            // Bottom gradient + time + save button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 6, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _relativeTime(item.postedAt),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onSave,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.cloud_download,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
