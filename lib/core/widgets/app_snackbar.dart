import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Solid, high-contrast success/failure snackbar — the GetX default
/// (dark-grey background, no icon) reads poorly against this app's
/// screens, so title/message color and background are set explicitly
/// against the app's semantic success/error tokens. Originally built for
/// the login result snackbar; shared so every other success/failure
/// snackbar in the app looks the same instead of falling back to the
/// plain default.
class AppSnackbar {
  const AppSnackbar._();

  static void show({required String title, required String message, required bool isSuccess}) {
    final Color color = isSuccess ? AppColors.success : AppColors.error;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: AppColors.onPrimary,
      icon: Icon(
        isSuccess ? Icons.check_circle_outline : Icons.error_outline,
        color: AppColors.onPrimary,
      ),
      shouldIconPulse: false,
      margin: const EdgeInsets.all(AppDimensions.spacingMd),
      borderRadius: AppDimensions.radiusMd,
      duration: Duration(seconds: isSuccess ? 2 : 3),
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
