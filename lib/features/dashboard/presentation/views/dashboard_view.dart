import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/bordered_surface_card.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../domain/entities/dashboard_artisan_summary_entity.dart';
import '../../domain/entities/dashboard_department_entity.dart';
import '../../domain/entities/dashboard_metal_loss_entity.dart';
import '../../domain/entities/dashboard_production_entity.dart';
import '../../domain/entities/dashboard_quality_inspection_entity.dart';
import '../../domain/entities/dashboard_target_achievement_entity.dart';
import '../controllers/dashboard_controller.dart';

/// Department overview: a department switcher on the left, and — for
/// whichever department is selected — five floor-status cards on the
/// right: Active Artisans, Today's Production, Quality Inspection, Target
/// and Achievement, and Metal Loss.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: AppStrings.dashboard,
        showNotification: false,
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DepartmentSidebar(controller: controller),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingDepartments.value ||
                    controller.isLoadingSummary.value) {
                  return const HkLoaderCard();
                }
                if (controller.selectedDepartment.value == null) {
                  return const AppEmptyWidget(
                    message: AppStrings.selectDepartmentPrompt,
                    icon: Icons.apartment_outlined,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isTablet =
                        constraints.maxWidth >= AppDimensions.breakpointPhone;

                    final Widget todaysProduction = _TodaysProductionCard(
                      data: controller.production.value!,
                      fillHeight: isTablet,
                    );
                    final Widget targetAchievement = _TargetAchievementCard(
                      data: controller.targetAchievement.value!,
                      fillHeight: isTablet,
                    );
                    final Widget activeArtisans = _ActiveArtisansCard(
                      data: controller.artisans.value!,
                      fillHeight: isTablet,
                    );
                    final Widget qualityInspection = _QualityInspectionCard(
                      data: controller.qualityInspection.value!,
                      fillHeight: isTablet,
                    );
                    final Widget metalLoss = _MetalLossCard(
                      data: controller.metalLoss.value!,
                      fillHeight: isTablet,
                    );

                    // Phone: natural card heights, page scrolls — forcing
                    // five full-height cards to fill a narrow, short
                    // viewport would squash them illegibly.
                    if (!isTablet) {
                      final List<Widget> cards = [
                        todaysProduction,
                        activeArtisans,
                        qualityInspection,
                        targetAchievement,
                        metalLoss,
                      ];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        child: Column(
                          children: [
                            for (final card in cards) ...[
                              card,
                              if (card != cards.last)
                                const SizedBox(height: AppDimensions.spacingMd),
                            ],
                          ],
                        ),
                      );
                    }

                    // Tablet: a two-column grid — left column holds Today's
                    // Production Status above the (taller) Target and
                    // Achievement card, right column holds the three
                    // remaining cards stacked evenly — filling the full
                    // available height with no page scroll, no blank space
                    // below the grid. Each card's own `Column` spaces its
                    // content out to its stretched height via a `Spacer`
                    // (see e.g. `_ActiveArtisansCard`) instead of leaving
                    // blank space at the card's own bottom.
                    return Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(child: todaysProduction),
                                const SizedBox(height: AppDimensions.spacingMd),
                                Expanded(flex: 2, child: targetAchievement),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingMd),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(child: activeArtisans),
                                const SizedBox(height: AppDimensions.spacingMd),
                                Expanded(child: qualityInspection),
                                const SizedBox(height: AppDimensions.spacingMd),
                                Expanded(child: metalLoss),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Department search + list — same shape as the app's other
/// `DepartmentSidebar` (search up top instead of a header label, since this
/// list is filterable).
class _DepartmentSidebar extends StatelessWidget {
  const _DepartmentSidebar({required this.controller});

  final DashboardController controller;

  static const double _width = 260;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: ColoredBox(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onQueryChanged,
                decoration: InputDecoration(
                  hintText: AppStrings.searchDepartment,
                  prefixIcon: const Icon(
                    Icons.search,
                    size: AppDimensions.iconSm,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingXs,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingDepartments.value) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                final List<DashboardDepartmentEntity> items =
                    controller.departments;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXs,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final DashboardDepartmentEntity department = items[i];
                    return Obx(() {
                      final bool selected =
                          controller.selectedDepartment.value?.id ==
                          department.id;
                      return _DepartmentTile(
                        name: department.name,
                        floorLabel: department.floorLabel,
                        selected: selected,
                        onTap: () => controller.selectDepartment(department),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({
    required this.name,
    required this.floorLabel,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String floorLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                if (selected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingXs,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                    ),
                    child: Text(
                      AppStrings.activeStatus,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  )
                else
                  Text(
                    floorLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small icon badge + title + a colored status pill on the trailing end —
/// the header row every one of the five overview cards starts with. The
/// icon gives each card a recognizable identity at a glance instead of all
/// five cards reading as identical white blocks.
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeContainerColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String badgeText;
  final Color badgeColor;
  final Color badgeContainerColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXs,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: badgeContainerColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Text(
            badgeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Section label (uppercase, muted) that introduces a card's secondary
/// content below its divider — gives the space under the divider a reason
/// to exist instead of reading as an accidental gap.
class _SectionCaption extends StatelessWidget {
  const _SectionCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Label above a bold value + muted unit, baseline-aligned — used for the
/// small stat groups on the Today's Production/Target and Achievement
/// cards.
class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimensions.spacingXxs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXxs),
            Text(
              unit,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Rounded track + fill, used by both Today's Production's "Completed"
/// meter and Metal Loss's "Monthly Buffer Usage" meter.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: AppColors.surfaceVariant,
        color: color,
      ),
    );
  }
}

class _ActiveArtisansCard extends StatelessWidget {
  const _ActiveArtisansCard({required this.data, required this.fillHeight});

  final DashboardArtisanSummaryEntity data;

  /// True on the tablet grid, where this card is stretched to a row's full
  /// height and needs a `Spacer` to push its bottom group down; false on
  /// phone, where the card sits in an unbounded-height scroll column and a
  /// `Spacer` there would crash (`Spacer` requires bounded space).
  final bool fillHeight;

  static const List<Color> _categoryColors = [
    AppColors.warning,
    AppColors.info,
    AppColors.textPrimary,
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // `Spacer` below sizes the Column to fit its stretched height with zero
    // slack, which can leave a sub-pixel (< 1px) rounding overflow on some
    // screen sizes/font scales; `ClipRect` clips it rather than let the
    // debug overflow banner draw over the card.
    return BorderedSurfaceCard(
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.groups_rounded,
              iconColor: AppColors.info,
              iconBackgroundColor: AppColors.infoContainer,
              title: AppStrings.activeArtisans,
              badgeText: '${data.onFloorPercent}% On Floor',
              badgeColor: AppColors.success,
              badgeContainerColor: AppColors.successContainer,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${data.activeCount}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXxs),
                Text(
                  '/ ${data.totalRoster} Total Floor Roster',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            // Absorbs the extra height from the row's `Expanded`/`stretch`
            // sizing so the category tiles sit pinned to the card's bottom
            // instead of leaving blank space there.
            if (fillHeight)
              const Spacer()
            else
              const SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                for (int i = 0; i < data.categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: _CategoryTile(
                      category: data.categories[i],
                      color: _categoryColors[i % _categoryColors.length],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.color});

  final DashboardArtisanCategoryEntity category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            '${category.count}',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            category.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysProductionCard extends StatelessWidget {
  const _TodaysProductionCard({required this.data, required this.fillHeight});

  final DashboardProductionEntity data;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasBacklog = data.totalBacklog > 0;
    final double percent = data.shiftTarget == 0
        ? 0
        : data.completed / data.shiftTarget;
    final int pace = data.paceVsStandard;
    final String paceSign = pace > 0 ? '+' : '';

    return BorderedSurfaceCard(
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.precision_manufacturing_rounded,
              iconColor: AppColors.primary,
              iconBackgroundColor: AppColors.primaryContainer,
              title: AppStrings.todaysProduction,
              badgeText: hasBacklog
                  ? 'Backlog Alert: ${data.totalBacklog} pcs'
                  : AppStrings.onTrack,
              badgeColor: hasBacklog ? AppColors.error : AppColors.success,
              badgeContainerColor: hasBacklog
                  ? AppColors.errorContainer
                  : AppColors.successContainer,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: AppStrings.shiftTarget,
                    value: '${data.shiftTarget}',
                    unit: 'pcs',
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: AppStrings.completed,
                    value: '${data.completed}',
                    unit: 'pcs',
                    valueColor: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: AppStrings.unresolvedBacklog,
                    value: '${data.totalBacklog}',
                    unit: 'pcs',
                    valueColor: AppColors.error,
                  ),
                ),
              ],
            ),
            if (fillHeight)
              const Spacer()
            else
              const SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                Text(
                  'Pace: $paceSign$pace pcs vs standard run',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(percent * 100).toStringAsFixed(1)}%',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            _ProgressBar(value: percent, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _QualityInspectionCard extends StatelessWidget {
  const _QualityInspectionCard({required this.data, required this.fillHeight});

  final DashboardQualityInspectionEntity data;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BorderedSurfaceCard(
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.fact_check_rounded,
              iconColor: AppColors.warning,
              iconBackgroundColor: AppColors.warningContainer,
              title: AppStrings.qualityInspection,
              badgeText: '${data.urgentCount} Urgent (>24h)',
              badgeColor: AppColors.warning,
              badgeContainerColor: AppColors.warningContainer,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${data.piecesWaiting}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXxs),
                Expanded(
                  child: Text(
                    AppStrings.piecesWaitingInQcLine,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            // A fixed `Spacer` + plain list here would overflow on shorter
            // screens once the card's guaranteed share of height can't fit
            // every boxed row — `Expanded` + scroll view instead lets the
            // list scroll internally rather than ever overflow the card.
            if (fillHeight)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final item in data.queue) _QcQueueRow(item: item),
                    ],
                  ),
                ),
              )
            else ...[
              const SizedBox(height: AppDimensions.spacingMd),
              for (final item in data.queue) _QcQueueRow(item: item),
            ],
          ],
        ),
      ),
    );
  }
}

class _QcQueueRow extends StatelessWidget {
  const _QcQueueRow({required this.item});

  final DashboardQcQueueItemEntity item;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ),
            Text(
              '${item.pieces} pcs',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetAchievementCard extends StatelessWidget {
  const _TargetAchievementCard({required this.data, required this.fillHeight});

  final DashboardTargetAchievementEntity data;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final int remaining = (data.weeklyTarget - data.outputToDate).clamp(
      0,
      data.weeklyTarget,
    );
    final double metPercent = data.weeklyTarget == 0
        ? 0
        : data.outputToDate / data.weeklyTarget * 100;

    return BorderedSurfaceCard(
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.track_changes_rounded,
              iconColor: AppColors.success,
              iconBackgroundColor: AppColors.successContainer,
              title: AppStrings.targetAndAchievement,
              badgeText: '${metPercent.toStringAsFixed(1)}% Met MTD',
              badgeColor: AppColors.success,
              badgeContainerColor: AppColors.successContainer,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: AppStrings.weeklyTarget,
                    value: '${data.weeklyTarget}',
                    unit: 'pcs',
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: AppStrings.outputToDate,
                    value: '${data.outputToDate}',
                    unit: 'pcs',
                    valueColor: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: AppStrings.remaining,
                    value: '$remaining',
                    unit: 'pcs',
                  ),
                ),
              ],
            ),
            if (fillHeight)
              const Spacer()
            else
              const SizedBox(height: AppDimensions.spacingMd),
            const _SectionCaption(AppStrings.dayToDayOutput),
            const SizedBox(height: AppDimensions.spacingSm),
            if (fillHeight)
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < data.days.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(child: _DayBar(day: data.days[i])),
                    ],
                  ],
                ),
              )
            else
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < data.days.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(child: _DayBar(day: data.days[i])),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One bar on the "Day-to-Day Output" chart — height proportional to
/// [DashboardDayEntity.percent], with that percentage labeled above.
class _DayBar extends StatelessWidget {
  const _DayBar({required this.day});

  final DashboardDayEntity day;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isCurrent = day.status == DashboardDayStatus.current;
    final Color barColor = switch (day.status) {
      DashboardDayStatus.completed => AppColors.success,
      DashboardDayStatus.current => AppColors.warning,
      DashboardDayStatus.upcoming => AppColors.surfaceVariant,
    };
    final double heightFactor = (day.percent.clamp(0, 100) / 100).clamp(
      0.03,
      1.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${day.percent}%',
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            color: isCurrent ? AppColors.warning : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              widthFactor: 0.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXxs),
        Text(
          day.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: isCurrent ? AppColors.warning : AppColors.textSecondary,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MetalLossCard extends StatelessWidget {
  const _MetalLossCard({required this.data, required this.fillHeight});

  final DashboardMetalLossEntity data;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final bool withinNorm = data.lossRatePercent <= data.normThreshold;

    return BorderedSurfaceCard(
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.water_drop_rounded,
              iconColor: AppColors.textPrimary,
              iconBackgroundColor: AppColors.surfaceVariant,
              title: AppStrings.metalLoss,
              badgeText:
                  'Rate: ${data.lossRatePercent.toStringAsFixed(2)}% (≤${data.normThreshold.toStringAsFixed(2)}%)',
              badgeColor: withinNorm ? AppColors.success : AppColors.error,
              badgeContainerColor: withinNorm
                  ? AppColors.successContainer
                  : AppColors.errorContainer,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            // Stacking both sub-cards full-width (rather than side by side)
            // can need more height than this card's guaranteed share on
            // shorter screens — `Expanded` + scroll view lets them scroll
            // internally instead of ever overflowing the card.
            if (fillHeight)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _MetalLossSubCard(
                        title: AppStrings.todaysGrossLoss,
                        value: data.todayGrossLoss.toStringAsFixed(3),
                        unit: 'g',
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      _MetalLossSubCard(
                        title: AppStrings.mtdLoss,
                        value: data.mtdLoss.toStringAsFixed(3),
                        unit: 'g',
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _MetalLossSubCard(
                title: AppStrings.todaysGrossLoss,
                value: data.todayGrossLoss.toStringAsFixed(3),
                unit: 'g',
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              _MetalLossSubCard(
                title: AppStrings.mtdLoss,
                value: data.mtdLoss.toStringAsFixed(3),
                unit: 'g',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetalLossSubCard extends StatelessWidget {
  const _MetalLossSubCard({
    required this.title,
    required this.value,
    required this.unit,
  });

  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXxs),
              Text(
                unit,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
