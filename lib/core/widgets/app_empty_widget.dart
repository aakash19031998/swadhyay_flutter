import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

/// Generic "no data" state for lists/reports.
class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    super.key,
    this.message = AppStrings.noDataFound,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.iconXl, color: colors.outlineVariant),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
