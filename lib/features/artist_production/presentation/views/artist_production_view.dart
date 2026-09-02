import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/date_range_filter_card.dart';
import '../../../../core/widgets/gradient_top_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/report_table.dart';
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
            const GradientTopBar(title: AppStrings.artistProductionReportTitle),
            Expanded(
              child: SingleChildScrollView(
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
                    Obx(() {
                      if (controller.isLoading.value) return const HkLoaderCard();
                      if (controller.errorMessage.value != null) {
                        return AppErrorWidget(message: controller.errorMessage.value!, onRetry: controller.show);
                      }
                      if (!controller.hasSearched.value) {
                        return const AppEmptyWidget(
                          message: AppStrings.selectDateRangeAndShow,
                          icon: Icons.event_note_outlined,
                        );
                      }

                      final TextTheme textTheme = Theme.of(context).textTheme;
                      final TextStyle? firstColumnStyle = textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      );

                      final Widget productionDetail = SectionCard(
                        title: AppStrings.productionDetail,
                        icon: Icons.insights_outlined,
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          child: ReportTable(
                            fillHeight: false,
                            columns: const [
                              ReportHeaderLabel(AppStrings.workType),
                              ReportHeaderLabel(AppStrings.work),
                              ReportHeaderLabel(AppStrings.actualPcsStone),
                              ReportHeaderLabel(AppStrings.totalPoints),
                            ],
                            rows: [
                              for (final entry in controller.items)
                                [
                                  ReportValueCell(text: entry.workType, style: firstColumnStyle),
                                  ReportValueCell(text: entry.work, style: textTheme.bodyMedium),
                                  ReportValueCell(text: '${entry.actualQty}', style: textTheme.bodyMedium),
                                  ReportValueCell(
                                    text: entry.totalPoints.toStringAsFixed(2),
                                    style: textTheme.bodyMedium,
                                  ),
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
                          child: ReportTable(
                            fillHeight: false,
                            columns: const [
                              ReportHeaderLabel(AppStrings.workType),
                              ReportHeaderLabel(AppStrings.actualPcsStone),
                              ReportHeaderLabel(AppStrings.totalPoints),
                            ],
                            rows: [
                              for (final entry in controller.summary)
                                [
                                  ReportValueCell(text: entry.workType, style: firstColumnStyle),
                                  ReportValueCell(text: '${entry.actualQty}', style: textTheme.bodyMedium),
                                  ReportValueCell(
                                    text: entry.totalPoints.toStringAsFixed(2),
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                            ],
                          ),
                        ),
                      );

                      return Column(
                        children: [
                          KpiRow(
                            cardsBuilder: () => [
                              KpiCard(
                                icon: Icons.inventory_2_outlined,
                                title: AppStrings.actualBagPieces,
                                value: '${controller.totalPieces}',
                                color: AppColors.info,
                                containerColor: AppColors.infoContainer,
                              ),
                              KpiCard(
                                icon: Icons.insights_outlined,
                                title: AppStrings.prediction,
                                value: '${controller.totalParts}',
                                color: AppColors.warning,
                                containerColor: AppColors.warningContainer,
                              ),
                              KpiCard(
                                icon: Icons.star_border_rounded,
                                title: AppStrings.totalPoints,
                                value: controller.totalPointsValue.toStringAsFixed(2),
                                color: AppColors.success,
                                containerColor: AppColors.successContainer,
                              ),
                            ],
                          ),
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

                              // Production Detail and Work Type Summary split the
                              // row equally. Deliberately CrossAxisAlignment.start
                              // (not .stretch/IntrinsicHeight) — each table's
                              // height should come from its own row count, not be
                              // forced to match the other's.
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: productionDetail),
                                  const SizedBox(width: AppDimensions.spacingMd),
                                  Expanded(child: workTypeSummary),
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

