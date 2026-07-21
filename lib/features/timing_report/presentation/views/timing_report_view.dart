import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/timing_report_entity.dart';
import '../controllers/timing_report_controller.dart';

/// Timing Report: a full-screen grouped bar chart, one pair of bars (used /
/// unused minutes) per day of the current calendar month. The bar count
/// always matches [TimingReportController.daysInMonth] — computed from the
/// real calendar, so it's 28 in February and 30/31 elsewhere, never
/// hardcoded. The plot fills whatever vertical space the device gives it
/// (computed in [_Chart] via [LayoutBuilder]) rather than a fixed height,
/// so it always occupies the full screen instead of leaving blank space.
class TimingReportView extends GetView<TimingReportController> {
  const TimingReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const AppLoader();
                if (controller.errorMessage.value != null) {
                  return AppErrorWidget(message: controller.errorMessage.value!, onRetry: controller.load);
                }

                return Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateTimeHelper.formatMonthYear(DateTime(controller.year, controller.month)),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Spacer(),
                            const _LegendChip(color: AppColors.success, label: AppStrings.usedMinutes),
                            const SizedBox(width: AppDimensions.spacingMd),
                            const _LegendChip(color: AppColors.chartAmber, label: AppStrings.unusedMinutes),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        Expanded(child: _Chart(entries: controller.entries)),
                      ],
                    ),
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
              AppStrings.timingReport,
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

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: AppDimensions.spacingXxs),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.entries});

  final List<TimingReportEntity> entries;

  static const double _columnWidth = AppDimensions.timingChartBarWidth * 2 +
      AppDimensions.timingChartBarGap +
      AppDimensions.timingChartDayColumnGap;

  int get _axisMax {
    int maxValue = 0;
    for (final entry in entries) {
      if (entry.usedMinutes > maxValue) maxValue = entry.usedMinutes;
      if (entry.unusedMinutes > maxValue) maxValue = entry.unusedMinutes;
    }
    if (maxValue == 0) return 200;
    return ((maxValue / 200).ceil()) * 200;
  }

  @override
  Widget build(BuildContext context) {
    final int axisMax = _axisMax;
    final List<int> ticks = [for (int i = 5; i >= 0; i--) (axisMax * i / 5).round()];
    final double contentWidth = entries.length * _columnWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double plotHeight = (constraints.maxHeight - AppDimensions.timingChartDayLabelHeight)
            .clamp(AppDimensions.timingChartMinPlotHeight, double.infinity);
        final double usableHeight = plotHeight - AppDimensions.timingChartLabelHeadroom;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _YAxis(ticks: ticks, plotHeight: plotHeight),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: contentWidth,
                      height: plotHeight,
                      child: Stack(
                        children: [
                          Positioned(
                            top: AppDimensions.timingChartLabelHeadroom,
                            left: 0,
                            right: 0,
                            height: usableHeight,
                            child: _GridLines(lineCount: ticks.length),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (final entry in entries)
                                _DayBars(
                                  entry: entry,
                                  axisMax: axisMax,
                                  plotHeight: plotHeight,
                                  usableHeight: usableHeight,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        for (final entry in entries)
                          SizedBox(
                            width: _columnWidth,
                            child: Center(
                              child: Text(
                                entry.date.day.toString().padLeft(2, '0'),
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _YAxis extends StatelessWidget {
  const _YAxis({required this.ticks, required this.plotHeight});

  final List<int> ticks;
  final double plotHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.timingChartYAxisWidth,
      height: plotHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: AppDimensions.timingChartLabelHeadroom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final tick in ticks)
              Text(
                '$tick',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridLines extends StatelessWidget {
  const _GridLines({required this.lineCount});

  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < lineCount; i++) Container(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _DayBars extends StatelessWidget {
  const _DayBars({
    required this.entry,
    required this.axisMax,
    required this.plotHeight,
    required this.usableHeight,
  });

  final TimingReportEntity entry;
  final int axisMax;
  final double plotHeight;
  final double usableHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _Chart._columnWidth,
      height: plotHeight,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(
              value: entry.usedMinutes,
              axisMax: axisMax,
              color: AppColors.success,
              plotHeight: plotHeight,
              usableHeight: usableHeight,
            ),
            const SizedBox(width: AppDimensions.timingChartBarGap),
            _Bar(
              value: entry.unusedMinutes,
              axisMax: axisMax,
              color: AppColors.chartAmber,
              plotHeight: plotHeight,
              usableHeight: usableHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.axisMax,
    required this.color,
    required this.plotHeight,
    required this.usableHeight,
  });

  final int value;
  final int axisMax;
  final Color color;
  final double plotHeight;
  final double usableHeight;

  @override
  Widget build(BuildContext context) {
    final double barHeight = axisMax == 0 ? 0 : (value / axisMax) * usableHeight;

    return SizedBox(
      width: AppDimensions.timingChartBarWidth,
      height: plotHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (value > 0) ...[
            Text(
              '$value',
              softWrap: false,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 2),
          ],
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}
