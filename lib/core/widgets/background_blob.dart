import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft translucent circle used as a decorative background accent — placed
/// off-canvas (partially clipped) behind the Login and Splash screens'
/// content.
class BackgroundBlob extends StatelessWidget {
  const BackgroundBlob({required this.size, required this.opacity, super.key});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.onPrimary.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
