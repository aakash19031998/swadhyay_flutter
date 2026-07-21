import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';

/// Generic error state with a retry action, shown when a use case returns a
/// [Failure].
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.message = AppStrings.somethingWentWrong,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: AppDimensions.iconXl, color: colors.error),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              AppButton(
                label: AppStrings.retry,
                onPressed: onRetry,
                variant: AppButtonVariant.outlined,
                fullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
