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
/// two tables — the detailed work-type entries (with prediction) and a
/// derived per-work-type summary (without prediction).
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
            _DateRangeBar(controller: controller),
            Expanded(
              child: Obx(() {
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: Column(
                    children: [
                      SectionCard(
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
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      SectionCard(
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
                      ),
                    ],
                  ),
                );
              }),
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

class _DateRangeBar extends StatelessWidget {
  const _DateRangeBar({required this.controller});

  final ArtistProductionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
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

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              for (final column in columns)
                Expanded(
                  child: Text(
                    column,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
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
                    for (final cell in rows[i])
                      Expanded(
                        child: Text(
                          cell,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
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
