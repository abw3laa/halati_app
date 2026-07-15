import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localization.dart';
import '../services/settings_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _versionLabel;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _versionLabel = '${info.version} (${info.buildNumber})');
  }

  Future<void> _checkForUpdate() async {
    setState(() => _checkingUpdate = true);
    final result = await UpdateService.instance.checkForUpdate(force: true);
    if (!mounted) return;
    setState(() => _checkingUpdate = false);

    if (result == null || !result.isUpdateAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(T(context, 'update_up_to_date'))),
      );
      return;
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: !result.isMandatory,
      builder: (_) => UpdateDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsService>();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: Text(T(context, 'settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                    icon: Icons.language, title: T(context, 'language')),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppLanguage>(
                  initialValue: settings.language,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: AppLanguage.values
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l.nativeName)))
                      .toList(),
                  onChanged: (l) {
                    if (l != null) {
                      context.read<SettingsService>().setLanguage(l);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dark mode
          _Card(
            child: Row(
              children: [
                Expanded(
                  child: _SectionHeader(
                    icon: Icons.dark_mode,
                    title: T(context, 'dark_mode'),
                    subtitle: T(context, 'dark_mode_desc'),
                  ),
                ),
                Switch(
                  value: settings.darkMode,
                  onChanged: (v) =>
                      context.read<SettingsService>().setDarkMode(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Storage path (informational only — retention/limits removed
          // per product decision: Halati now always keeps a deleted
          // status visible until its real 24h WhatsApp lifetime ends,
          // so a user-configurable retention setting no longer applies).
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                    icon: Icons.folder_open, title: T(context, 'storage_path')),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'storage/emulated/0/halati/download',
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: scheme.secondaryContainer),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(T(context, 'storage_path_desc'),
                          style: TextStyle(
                              fontSize: 13, color: scheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Updates (self-hosted, outside Google Play)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.system_update_alt,
                  title: T(context, 'settings_check_updates'),
                  subtitle: _versionLabel == null
                      ? null
                      : '${T(context, 'settings_current_version')}: $_versionLabel',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _checkingUpdate ? null : _checkForUpdate,
                    icon: _checkingUpdate
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 18),
                    label: Text(_checkingUpdate
                        ? T(context, 'update_checking')
                        : T(context, 'settings_check_updates')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          _Card(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            child: Row(
              children: [
                Expanded(
                    child: _SectionHeader(
                        icon: Icons.info, title: T(context, 'about_title'))),
                Icon(Icons.chevron_left, color: scheme.onSurfaceVariant),
              ],
            ),
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await Share.share(
                'حالاتي — تطبيق حفظ حالات واتساب: https://play.google.com/store/apps',
                subject: 'حالاتي',
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.share),
            label: Text(T(context, 'share_app')),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () =>
                  launchUrl(Uri.parse('https://example.com/privacy')),
              child: Text(T(context, 'privacy_policy')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
        borderRadius: BorderRadius.circular(16), onTap: onTap, child: card);
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  const _SectionHeader({this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: scheme.secondary),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
