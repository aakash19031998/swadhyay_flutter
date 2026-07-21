import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Default landing content behind the drawer — the branded dashboard
/// banner, centered and capped to a sensible max width on large tablets.
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth * 1.5),
        child: Image.asset(AppAssets.homeBackground, fit: BoxFit.contain),
      ),
    );
  }
}
