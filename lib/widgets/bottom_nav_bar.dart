import 'package:flutter/material.dart';
import '../l10n/app_localization.dart';
import '../theme/app_theme.dart';

class HalatiBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const HalatiBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final items = [
      (Icons.auto_awesome_rounded, T(context, 'nav_updates')),
      (Icons.download_rounded, T(context, 'nav_download')),
      (Icons.tune_rounded, T(context, 'nav_settings')),
    ];
    return Container(
      decoration: BoxDecoration(
        color: s.surfaceContainerLowest,
        border: Border(top: BorderSide(color: s.outlineVariant.withValues(alpha: .35))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              final (icon, label) = items[i];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? s.primaryContainer : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 22, color: active ? s.onPrimaryContainer : s.onSurfaceVariant),
                          const SizedBox(height: 2),
                          Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? s.onPrimaryContainer : s.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
