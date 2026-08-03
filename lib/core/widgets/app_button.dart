import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../network/connectivity_checker.dart';

enum AppButtonVariant { filled, outlined, text }

/// Standard button used across every form/action in the app so tap targets,
/// loading affordance and disabled styling stay consistent.
///
/// Every tap is gated behind [ConnectivityChecker] first — offline taps
/// show the shared "no internet" snackbar and never reach [onPressed] — so
/// no screen needs its own pre-flight connectivity check on a button.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  Future<void> _handleTap() async {
    final VoidCallback? callback = onPressed;
    if (callback == null) return;
    if (!await Get.find<ConnectivityChecker>().ensureConnected()) return;
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final Widget child = isLoading
        ? SizedBox(
            height: AppDimensions.iconMd,
            width: AppDimensions.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.filled
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        : icon == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppDimensions.iconMd),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Text(label),
                ],
              );

    final Widget button = switch (variant) {
      AppButtonVariant.filled => ElevatedButton(onPressed: isDisabled ? null : _handleTap, child: child),
      AppButtonVariant.outlined => OutlinedButton(onPressed: isDisabled ? null : _handleTap, child: child),
      AppButtonVariant.text => TextButton(onPressed: isDisabled ? null : _handleTap, child: child),
    };

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
