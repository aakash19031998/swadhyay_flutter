import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Rounded, bordered, subtly-shadowed surface — the floating-card look used
/// by the date-range filter card, KPI cards, and the Timing Report month
/// filter card. Deliberately distinct from [AppCard] (a Material [Card]
/// with its own elevation/shape), which renders differently.
class BorderedSurfaceCard extends StatelessWidget {
  const BorderedSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppDimensions.spacingMd),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
