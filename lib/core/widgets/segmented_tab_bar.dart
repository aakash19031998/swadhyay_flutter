import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Pill-segmented tab bar — a filled pill indicator sliding between
/// equal-width segments — used by Bag Detail (text-only tabs) and Design
/// Image (icon-above/beside-label tabs). [tabs] carries whatever content
/// each screen's segments need.
class SegmentedTabBar extends StatelessWidget {
  const SegmentedTabBar({
    required this.tabController,
    required this.tabs,
    super.key,
    this.onTap,
    this.backgroundColor = AppColors.surfaceVariant,
  });

  final TabController tabController;
  final List<Widget> tabs;

  /// Fires whenever any segment is tapped (including re-tapping the
  /// already-selected one) — e.g. so a screen can reset other state on a
  /// switch. Left null where a screen only needs the tab switch itself
  /// (Bag Detail, Design Image).
  final ValueChanged<int>? onTap;

  /// Color behind the unselected track — defaults to the light lavender
  /// Bag Detail/Design Image use; QC Pending Dashboard overrides to plain
  /// white to match its own app bar.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        child: SizedBox(
          height: AppDimensions.bagDetailSegmentedTabBarHeight,
          child: TabBar(
            controller: tabController,
            onTap: onTap,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppColors.onPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            tabs: tabs,
          ),
        ),
      ),
    );
  }
}
