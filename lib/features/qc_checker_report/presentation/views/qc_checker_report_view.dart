import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/date_range_filter_card.dart';
import '../../../../core/widgets/gradient_top_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/report_table.dart';
import '../../domain/entities/qc_checker_report_entity.dart';
import '../controllers/qc_checker_report_controller.dart';

/// QC Checker Report — same "From/To date range + Show" shape as
/// `ArtistProductionView`, but with two different tables: a "QC Prediction
/// Score Matrix" (per-prediction rows) and a "Shift & Process Distribution"
/// (per-process rows split by Day/Evening shift), each with its own footer
/// (a total-points bar, and a Day/Evening percentage bar respectively).
class QcCheckerReportView extends GetView<QcCheckerReportController> {
  const QcCheckerReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const GradientTopBar(title: AppStrings.qcCheckerReportTitle),
            // Fills the rest of the screen (rather than one big
            // `SingleChildScrollView`) so the table cards below can each
            // stretch to fill the remaining height and scroll their own
            // rows internally — the "Total Points"/shift-percentage
            // footers stay pinned right where they are instead of
            // requiring a further page-scroll to bring into view.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  children: [
                    DateRangeFilterCard(
                      fromDate: controller.fromDate,
                      toDate: controller.toDate,
                      isLoading: controller.isLoading,
                      onPickFromDate: controller.pickFromDate,
                      onPickToDate: controller.pickToDate,
                      onShow: controller.show,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const HkLoaderCard();
                        }
                        if (controller.errorMessage.value != null) {
                          return AppErrorWidget(
                            message: controller.errorMessage.value!,
                            onRetry: controller.show,
                          );
                        }
                        if (!controller.hasSearched.value) {
                          return const AppEmptyWidget(
                            message: AppStrings.selectDateRangeAndShow,
                            icon: Icons.event_note_outlined,
                          );
                        }

                        final Widget predictionScoreMatrix =
                            _PredictionScoreMatrixCard(controller: controller);
                        final Widget shiftDistribution = _ShiftDistributionCard(
                          controller: controller,
                        );

                        return Column(
                          children: [
                            KpiRow(
                              cardsBuilder: () => [
                                KpiCard(
                                  icon: Icons.military_tech_outlined,
                                  title: AppStrings.totalPoints,
                                  value: controller.totalPointsValue.value
                                      .toStringAsFixed(2),
                                  color: AppColors.textPrimary,
                                  containerColor: AppColors.primaryContainer,
                                ),
                                KpiCard(
                                  icon: Icons.inventory_2_outlined,
                                  title: AppStrings.totalBagsUnits,
                                  value: '${controller.totalBagPieces.value}',
                                  color: AppColors.info,
                                  containerColor: AppColors.infoContainer,
                                ),
                                KpiCard(
                                  icon: Icons.done_all_rounded,
                                  title: AppStrings.repairsCaught,
                                  value: '${controller.totalRepairCaught.value}',
                                  color: AppColors.success,
                                  containerColor: AppColors.successContainer,
                                ),
                                KpiCard(
                                  icon: Icons.warning_amber_rounded,
                                  title: AppStrings.ownRepairOffset,
                                  value: controller.ownRepairPoints.value
                                      .toStringAsFixed(2),
                                  valueSuffix:
                                      '(${controller.ownRepairBags.value} bags)',
                                  color: AppColors.error,
                                  containerColor: AppColors.errorContainer,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacingMd),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final bool isTablet =
                                      constraints.maxWidth >=
                                      AppDimensions.breakpointPhone;

                                  if (!isTablet) {
                                    return Column(
                                      children: [
                                        Expanded(child: predictionScoreMatrix),
                                        const SizedBox(
                                          height: AppDimensions.spacingMd,
                                        ),
                                        // Not `Expanded` — this card wraps
                                        // its own content height instead
                                        // of being forced to match the
                                        // other's (see `_ReportTable`'s
                                        // `fillHeight` doc comment).
                                        shiftDistribution,
                                      ],
                                    );
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: predictionScoreMatrix),
                                      const SizedBox(
                                        width: AppDimensions.spacingMd,
                                      ),
                                      Expanded(child: shiftDistribution),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
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

/// Small bordered chip for a process code (e.g. "F", "EF") — same idea as
/// the bag list card's own process `_Pill`, just compact enough for a table
/// cell instead of a card corner.
/// Plain bold/primary-colored text — no bordered chip/pill background,
/// matching `ArtistProductionView`'s own first-column styling (a chip was
/// tried there too and dropped: it didn't line up with the plain header
/// text above it once centered — see `_ReportCell`'s doc comment there).
class _ProcessCell extends StatelessWidget {
  const _ProcessCell(this.process);

  final String process;

  @override
  Widget build(BuildContext context) {
    return Text(
      process,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// A header cell with an icon above its label — used only for the shift
/// distribution table's two time-window columns.
class _HeaderIconLabel extends StatelessWidget {
  const _HeaderIconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: AppColors.onPrimary),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// The Prediction Score Matrix's dark total-points bar — same rounded
/// bottom corners as the table above it, since it renders as the table's
/// own last "row" (see `_ReportTable.footer`).
class _TotalPointsFooter extends StatelessWidget {
  const _TotalPointsFooter({required this.totalPoints});

  final double totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPrimary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.totalPoints.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Text(
            totalPoints.toStringAsFixed(2),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Day/Evening bag-count split, shown below the Shift & Process
/// Distribution table — a two-color bar plus the exact counts/percentages
/// on either end.
class _ShiftPercentageBar extends StatelessWidget {
  const _ShiftPercentageBar({required this.dayBags, required this.eveningBags});

  final int dayBags;
  final int eveningBags;

  @override
  Widget build(BuildContext context) {
    final int total = dayBags + eveningBags;
    final double dayFraction = total == 0 ? 0 : dayBags / total;
    final double dayPercent = dayFraction * 100;
    final double eveningPercent = total == 0 ? 0 : 100 - dayPercent;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Two `Expanded` segments in a `Row`, not a `FractionallySizedBox`
    // layered over a background color — that approach quietly collapsed
    // the whole bar to just the day-shift width instead of showing the
    // remaining (evening) color, since `FractionallySizedBox` sizes
    // *itself* down to its child's size rather than filling the bar.
    final int dayFlex = (dayFraction * 1000).round().clamp(0, 1000);
    final int eveningFlex = 1000 - dayFlex;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${AppStrings.dayShiftLabel} ($dayBags ${AppStrings.bagsSuffix} / ${dayPercent.toStringAsFixed(1)}%)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Flexible(
                child: Text(
                  '${AppStrings.eveningShiftLabel} ($eveningBags ${AppStrings.bagsSuffix} / ${eveningPercent.toStringAsFixed(1)}%)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: SizedBox(
              height: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (dayFlex > 0)
                    Expanded(
                      flex: dayFlex,
                      child: const ColoredBox(color: AppColors.warning),
                    ),
                  if (eveningFlex > 0)
                    Expanded(
                      flex: eveningFlex,
                      child: const ColoredBox(color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionScoreMatrixCard extends StatelessWidget {
  const _PredictionScoreMatrixCard({required this.controller});

  final QcCheckerReportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<QcPredictionScoreEntity> items =
          controller.predictionScoreMatrix;
      return AppCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: ReportTable(
            columns: const [
              ReportHeaderLabel(AppStrings.qcProcess),
              ReportHeaderLabel(AppStrings.qcPrediction),
              ReportHeaderLabel(AppStrings.totalPoints),
              ReportHeaderLabel(AppStrings.repairCaught),
            ],
            rows: [
              for (final item in items)
                [
                  _ProcessCell(item.process),
                  Text(item.prediction, textAlign: TextAlign.center),
                  Text(
                    item.totalPoints.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                  ),
                  Text('${item.repairCaught}', textAlign: TextAlign.center),
                ],
            ],
            footer: _TotalPointsFooter(
              totalPoints: controller.totalPointsValue.value,
            ),
          ),
        ),
      );
    });
  }
}

class _ShiftDistributionCard extends StatelessWidget {
  const _ShiftDistributionCard({required this.controller});

  final QcCheckerReportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<QcShiftDistributionEntity> items =
          controller.shiftProcessDistribution;
      return AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: ReportTable(
                fillHeight: false,
                columns: const [
                  ReportHeaderLabel(AppStrings.qcProcess),
                  ReportHeaderLabel(AppStrings.bagPieces),
                  ReportHeaderLabel(AppStrings.points),
                  ReportHeaderLabel(AppStrings.repair),
                  _HeaderIconLabel(
                    icon: Icons.wb_sunny_outlined,
                    label: AppStrings.dayShiftColumn,
                  ),
                  _HeaderIconLabel(
                    icon: Icons.dark_mode_outlined,
                    label: AppStrings.eveningShiftColumn,
                  ),
                ],
                rows: [
                  for (final item in items)
                    [
                      _ProcessCell(item.process),
                      Text('${item.emrBag}', textAlign: TextAlign.center),
                      Text(
                        item.points.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                      ),
                      Text('${item.repair}', textAlign: TextAlign.center),
                      Text('${item.dayShiftBags}', textAlign: TextAlign.center),
                      Text(
                        '${item.eveningShiftBags}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                ],
              ),
            ),
            _ShiftPercentageBar(
              dayBags: controller.totalDayShiftBags.value,
              eveningBags: controller.totalEveningShiftBags.value,
            ),
          ],
        ),
      );
    });
  }
}
