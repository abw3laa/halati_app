import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localization.dart';
import '../models/status_item.dart';
import '../services/settings_service.dart';
import '../services/status_service.dart';
import '../widgets/status_ring.dart';
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
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _MyStatusTile(),
                  const SizedBox(height: 24),
                  if (_items.isEmpty) _EmptyState(onGrantAccess: _grantAccess),
                  if (_items.isNotEmpty) ...[
                    if (_items.any((e) => !e.viewed)) ...[
                      Text(T(context, 'recent_updates'),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      _StatusList(
                        items: _items.where((e) => !e.viewed).toList(),
                        onOpen: _open,
                        onSave: _saveStatus,
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (_items.any((e) => e.viewed)) ...[
                      Text(T(context, 'viewed_updates'),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      _StatusList(
                        items: _items.where((e) => e.viewed).toList(),
                        onOpen: _open,
                        onSave: _saveStatus,
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
          Stack(
            children: [
              const StatusRing(size: 50, viewed: true),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: scheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ),
            ],
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

class _StatusList extends StatelessWidget {
  final List<StatusItem> items;
  final ValueChanged<StatusItem> onOpen;
  final ValueChanged<StatusItem> onSave;

  const _StatusList(
      {required this.items, required this.onOpen, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: ListTile(
              onTap: () => onOpen(item),
              leading: StatusRing(imagePath: item.path, viewed: item.viewed),
              title: const Text('Status', maxLines: 1),
              subtitle: Row(
                children: [
                  Icon(
                    item.type == StatusMediaType.video
                        ? Icons.movie
                        : Icons.image,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(_relativeTime(item.postedAt),
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  if (item.deletedByOwner) ...[
                    const SizedBox(width: 6),
                    const Text('🚫', style: TextStyle(fontSize: 13)),
                  ],
                ],
              ),
              trailing: IconButton(
                onPressed: () => onSave(item),
                icon: Icon(Icons.cloud_download,
                    color: scheme.onTertiaryContainer),
              ),
            ),
          );
        }).toList(),
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
