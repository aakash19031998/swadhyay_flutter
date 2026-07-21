import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Centered, full-space loading indicator used for a screen/section's
/// loading state.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
