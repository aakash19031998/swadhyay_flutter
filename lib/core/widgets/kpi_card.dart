import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';
import 'bordered_surface_card.dart';

/// Icon-left square badge, uppercase label + big bold value stacked to its
/// right — used by both the Artist Production Report and QC Checker Report
/// KPI strips. [valueSuffix] (e.g. "(3 bags)") is only used by QC Checker
/// Report; left null elsewhere, which renders identically to a plain value.
class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.containerColor,
    super.key,
    this.valueSuffix,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? valueSuffix;
  final Color color;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BorderedSurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatarSm,
            height: AppDimensions.avatarSm,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconMd),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color),
                    ),
                    if (valueSuffix != null) ...[
                      const SizedBox(width: AppDimensions.spacingXs),
                      Text(
                        valueSuffix!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.7)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive strip of [KpiCard]s — side by side on tablet width, stacked on
/// phone. [cardsBuilder] runs inside this widget's own `Obx`, exactly as
/// each screen's own KPI row used to build its card list inline, so the
/// same fine-grained rebuild dependency tracking is kept.
class KpiRow extends StatelessWidget {
  const KpiRow({required this.cardsBuilder, super.key});

  final List<Widget> Function() cardsBuilder;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Widget> cards = cardsBuilder();

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

          if (!isTablet) {
            return Column(
              children: [
                for (final card in cards) ...[
                  card,
                  if (card != cards.last) const SizedBox(height: AppDimensions.spacingSm),
                ],
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          );
        },
      );
    });
  }
}
