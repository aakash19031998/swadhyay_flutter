import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';

/// Static helpers around [Get.dialog] so every confirm/info dialog in the
/// app looks and behaves the same.
class AppDialog {
  const AppDialog._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
  }) async {
    final bool? result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel),
          ),
          AppButton(
            label: confirmLabel,
            fullWidth: false,
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> info({
    required String title,
    required String message,
    String buttonLabel = AppStrings.ok,
  }) {
    return Get.dialog<void>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: buttonLabel,
            fullWidth: false,
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  static void loading() {
    Get.dialog<void>(
      const PopScope(
        canPop: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacingLg),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void dismiss() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
