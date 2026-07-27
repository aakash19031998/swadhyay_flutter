import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_card.dart';
import '../controllers/artist_production_controller.dart';

/// Artist Production Report: pick a From/To date range, tap Show, then read
/// a KPI summary strip and two tables — the detailed work-type entries
/// (with prediction) and a derived per-work-type summary (without
/// prediction).
class ArtistProductionView extends GetView<ArtistProductionController> {
  const ArtistProductionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  children: [
                    _FilterCard(controller: controller),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Obx(() {
                      if (controller.isLoading.value) return const AppLoader();
                      if (controller.errorMessage.value != null) {
                        return AppErrorWidget(message: controller.errorMessage.value!, onRetry: controller.show);
                      }
                      if (!controller.hasSearched.value) {
                        return const AppEmptyWidget(
                          message: AppStrings.selectDateRangeAndShow,
                          icon: Icons.event_note_outlined,
                        );
                      }

                      final Widget productionDetail = SectionCard(
                        title: AppStrings.productionDetail,
                        icon: Icons.insights_outlined,
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          child: _ReportTable(
                            columns: const [
                              AppStrings.workType,
                              AppStrings.prediction,
                              AppStrings.actualPcsStone,
                              AppStrings.totalPoints,
                            ],
                            rows: [
                              for (final entry in controller.items)
                                [
                                  entry.workType,
                                  entry.prediction.toStringAsFixed(2),
                                  '${entry.actualQty}',
                                  entry.totalPoints.toStringAsFixed(2),
                                ],
                            ],
                          ),
                        ),
                      );

                      final Widget workTypeSummary = SectionCard(
                        title: AppStrings.workTypeSummary,
                        icon: Icons.summarize_outlined,
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          child: _ReportTable(
                            columns: const [
                              AppStrings.workType,
                              AppStrings.actualPcsStone,
                              AppStrings.totalPoints,
                            ],
                            rows: [
                              for (final entry in controller.summary)
                                [
                                  entry.workType,
                                  '${entry.actualQty}',
                                  entry.totalPoints.toStringAsFixed(2),
                                ],
                            ],
                          ),
                        ),
                      );

                      return Column(
                        children: [
                          _KpiRow(controller: controller),
                          const SizedBox(height: AppDimensions.spacingMd),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

                              if (!isTablet) {
                                return Column(
                                  children: [
                                    productionDetail,
                                    const SizedBox(height: AppDimensions.spacingMd),
                                    workTypeSummary,
                                  ],
                                );
                              }

                              // Production Detail (4 columns) gets more width than
                              // Work Type Summary (3 columns), roughly matching
                              // their column-count ratio. Deliberately
                              // CrossAxisAlignment.start (not .stretch/
                              // IntrinsicHeight) — each table's height should
                              // come from its own row count, not be forced to
                              // match the other's.
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 4, child: productionDetail),
                                  const SizedBox(width: AppDimensions.spacingMd),
                                  Expanded(flex: 3, child: workTypeSummary),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
              onPressed: Get.back,
            ),
            Text(
              AppStrings.artistProductionReportTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date-range filter as its own floating card (rounded, bordered, shadowed)
/// instead of a flush full-width bar, so it reads as one section among
/// several scrollable cards rather than a fixed toolbar.
class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.controller});

  final ArtistProductionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

          final Widget fromField = Obx(
            () => _DateField(
              label: AppStrings.fromDate,
              date: controller.fromDate.value,
              onTap: () => controller.pickFromDate(context),
            ),
          );
          final Widget toField = Obx(
            () => _DateField(
              label: AppStrings.toDate,
              date: controller.toDate.value,
              onTap: () => controller.pickToDate(context),
            ),
          );
          final Widget showButton = Obx(
            () => AppButton(
              label: AppStrings.show,
              icon: Icons.search,
              fullWidth: false,
              isLoading: controller.isLoading.value,
              onPressed: controller.show,
            ),
          );

          if (isTablet) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: fromField),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(child: toField),
                const SizedBox(width: AppDimensions.spacingMd),
                showButton,
              ],
            );
          }

          return Column(
            children: [
              fromField,
              const SizedBox(height: AppDimensions.spacingSm),
              toField,
              const SizedBox(height: AppDimensions.spacingSm),
              Align(alignment: Alignment.centerRight, child: showButton),
            ],
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: AppDimensions.iconSm),
        ),
        child: Text(DateTimeHelper.formatDate(date)),
      ),
    );
  }
}

/// Actual Bag Pieces / Prediction / Total Points at a glance, above the
/// detail tables — side by side on tablet width, stacked on phone. Values
/// are unchanged from before (still bound to the same underlying totals);
/// only the labels, icons, and colors were redesigned.
class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.controller});

  final ArtistProductionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Widget> cards = [
        _KpiCard(
          icon: Icons.inventory_2_outlined,
          title: AppStrings.actualBagPieces,
          value: controller.totalPrediction.toStringAsFixed(2),
          color: AppColors.info,
          containerColor: AppColors.infoContainer,
        ),
        _KpiCard(
          icon: Icons.insights_outlined,
          title: AppStrings.prediction,
          value: '${controller.totalActualQty}',
          color: AppColors.warning,
          containerColor: AppColors.warningContainer,
        ),
        _KpiCard(
          icon: Icons.star_border_rounded,
          title: AppStrings.totalPoints,
          value: controller.totalPoints.toStringAsFixed(2),
          color: AppColors.success,
          containerColor: AppColors.successContainer,
        ),
      ];

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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.containerColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
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
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          child: Row(
            children: [
              for (int i = 0; i < columns.length; i++)
                Expanded(
                  child: _ReportCell(
                    text: columns[i],
                    alignEnd: i != 0,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Text(
              AppStrings.noDataFound,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
            ),
          )
        else
          for (int i = 0; i < rows.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                color: i.isEven ? AppColors.surface : AppColors.surfaceVariant,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                child: Row(
                  children: [
                    for (int c = 0; c < rows[i].length; c++)
                      Expanded(
                        child: _ReportCell(
                          text: rows[i][c],
                          alignEnd: c != 0,
                          style: c == 0
                              ? textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)
                              : textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

/// One header or value cell. Header and value cells always go through this
/// same widget (same [Align], same lack of extra padding) so a column's
/// header and its values are guaranteed to line up pixel-for-pixel — unlike
/// before, when the work-type value was wrapped in a padded pill that the
/// plain header text didn't account for.
class _ReportCell extends StatelessWidget {
  const _ReportCell({required this.text, required this.alignEnd, this.style});

  final String text;
  final bool alignEnd;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
    );
  }
}
