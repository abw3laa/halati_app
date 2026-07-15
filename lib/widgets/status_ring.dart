import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular avatar with a segmented ring — solid "communication green"
/// gradient for unviewed statuses, light gray for viewed ones.
class StatusRing extends StatelessWidget {
  final String? imagePath;
  final bool viewed;
  final double size;

  const StatusRing({
    super.key,
    this.imagePath,
    this.viewed = false,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: viewed
            ? null
            : const LinearGradient(
                colors: [AppColors.waGreenStart, AppColors.waGreenEnd],
              ),
        color: viewed ? AppColors.outlineVariant : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(
          child: imagePath != null && File(imagePath!).existsSync()
              ? Image.file(File(imagePath!), fit: BoxFit.cover)
              : Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.person, color: AppColors.outline),
                ),
        ),
      ),
    );
  }
}
