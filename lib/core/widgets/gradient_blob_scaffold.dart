import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'background_blob.dart';

/// Full-screen gradient background with two decorative [BackgroundBlob]s
/// (top-right and bottom-left, partially off-canvas) behind a [SafeArea]
/// child — the shared shell for the Login and Splash screens.
class GradientBlobScaffold extends StatelessWidget {
  const GradientBlobScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            const Positioned(top: -80, right: -60, child: BackgroundBlob(size: 220, opacity: 0.10)),
            const Positioned(bottom: -100, left: -70, child: BackgroundBlob(size: 260, opacity: 0.08)),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
