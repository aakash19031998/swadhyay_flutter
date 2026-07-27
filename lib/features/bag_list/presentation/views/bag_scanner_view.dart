import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/bag_scanner_controller.dart';

/// Full-screen QR/barcode scanner: a live decode loop on the front-facing
/// camera only (never the rear camera). The first code read — QR or 1D
/// barcode — closes the screen and returns its value to the caller.
/// Permission-denied gets its own explained, actionable screen instead of a
/// blank preview.
class BagScannerView extends GetView<BagScannerController> {
  const BagScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: _ScannerFrame(
                child: MobileScanner(
                  controller: controller.scannerController,
                  onDetect: controller.onDetect,
                  errorBuilder: (context, error) {
                    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                      return _ScannerMessage(
                        icon: Icons.no_photography_outlined,
                        title: AppStrings.cameraPermissionDeniedTitle,
                        message: AppStrings.cameraPermissionDeniedMessage,
                        actionLabel: AppStrings.openSettings,
                        onAction: controller.openSettings,
                      );
                    }
                    return _ScannerMessage(
                      icon: Icons.camera_alt_outlined,
                      title: AppStrings.scanBag,
                      message: error.errorCode.message,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXs,
        vertical: AppDimensions.spacingXs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
            onPressed: Get.back,
          ),
          Text(
            AppStrings.scanBag,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Clips the live preview to a square viewfinder with corner brackets — the
/// familiar "scanner" affordance instead of a bare full-bleed camera feed.
class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: child,
            ),
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.8), width: 3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerMessage extends StatelessWidget {
  const _ScannerMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppDimensions.iconXl, color: AppColors.onPrimary.withValues(alpha: 0.7)),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
