import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_strings.dart';
import 'app_button.dart';
import 'hk_loader_card.dart';

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

  /// True only while a dialog opened by [loading] is on screen — tracked
  /// ourselves instead of trusting [Get.isDialogOpen]. That flag is a
  /// single global "is *any* dialog open" bit shared across the whole app;
  /// after a different dialog (e.g. `PauseReasonDialog`) opens and closes
  /// right before this one, it can end up desynced — [dismiss] would then
  /// see it as `false` and skip popping, leaving [loading]'s dialog stuck
  /// on screen forever even though the work it was waiting on already
  /// finished. This was reproduced live: pause a bag with a reason, then
  /// open a bag's image gallery — the loading card never went away even
  /// though the underlying fetch completed successfully.
  static bool _isLoadingDialogOpen = false;

  static void loading() {
    if (_isLoadingDialogOpen) return;
    _isLoadingDialogOpen = true;
    Get.dialog<void>(
      const PopScope(
        canPop: false,
        child: HkLoaderCard(),
      ),
      barrierDismissible: false,
    ).then((_) => _isLoadingDialogOpen = false);
  }

  static void dismiss() {
    if (!_isLoadingDialogOpen) return;
    _isLoadingDialogOpen = false;
    Get.back();
  }
}
