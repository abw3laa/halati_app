import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localization.dart';
import '../utils/app_links.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: Text(T(context, 'about_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)],
                  ),
                  child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text(T(context, 'app_name'),
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: scheme.primary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: scheme.secondary),
                      const SizedBox(width: 4),
                      Text('v2.0', style: TextStyle(color: scheme.secondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Developer card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(T(context, 'developer'),
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    const Text('ياسر أبو علاء', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Features
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: scheme.primaryContainer),
                    const SizedBox(width: 8),
                    Text(T(context, 'app_features'),
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: scheme.primaryContainer)),
                  ],
                ),
                const SizedBox(height: 16),
                _Feature(icon: Icons.download_done, text: T(context, 'feature_1')),
                _Feature(icon: Icons.dashboard_customize, text: T(context, 'feature_2')),
                _Feature(icon: Icons.dark_mode, text: T(context, 'feature_3')),
                _Feature(icon: Icons.folder_open, text: T(context, 'feature_4')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(T(context, 'contact_developer'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ContactButton(
                      iconAsset: 'assets/icons/whatsapp.png',
                      label: T(context, 'whatsapp'),
                      onTap: () => launchUrl(
                        Uri.parse('https://wa.me/905354883886'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    _ContactButton(
                      iconAsset: 'assets/icons/telegram.png',
                      label: T(context, 'telegram'),
                      onTap: () => launchUrl(
                        Uri.parse('https://t.me/abw3laa'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    _ContactButton(
                      iconAsset: 'assets/icons/facebook.png',
                      label: T(context, 'facebook'),
                      onTap: () => launchUrl(
                        Uri.parse('https://www.facebook.com/share/1VVyDNZUEk/'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(AppLinks.privacyPolicyUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.policy, size: 18),
                  label: Text(T(context, 'privacy_policy')),
                ),
                const SizedBox(height: 8),
                Text(T(context, 'all_rights'),
                    style: TextStyle(fontSize: 11, color: scheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.onTertiaryContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  const _ContactButton(
      {required this.iconAsset, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Image.asset(iconAsset, width: 26, height: 26),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
