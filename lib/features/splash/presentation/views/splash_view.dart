import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -60,
              child: _BackgroundBlob(size: 220, opacity: 0.10),
            ),
            const Positioned(
              bottom: -100,
              left: -70,
              child: _BackgroundBlob(size: 260, opacity: 0.08),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double side = constraints.biggest.shortestSide * 0.5;
                  final double gifSize = side.clamp(160.0, 320.0);

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: gifSize,
                          height: gifSize,
                          padding: const EdgeInsets.all(AppDimensions.spacingMd),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.splashGif,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),
                        Text(
                          AppStrings.appName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({required this.size, required this.opacity});

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
