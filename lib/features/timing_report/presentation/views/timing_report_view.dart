import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown.dart';
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MonthFilterCard(controller: controller),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _TillDateSummaryCard(
                        usedMinutes: controller.totalUsedMinutes,
                        unusedMinutes: controller.totalUnusedMinutes,
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _SectionIcon(icon: Icons.bar_chart_rounded, color: AppColors.primary),
                                  const SizedBox(width: AppDimensions.spacingSm),
                                  Text(
                                    AppStrings.dailyBreakdown,
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

/// Small rounded-square icon badge used as the leading element of every
/// section header on this screen — consistent with the icon-badge language
/// used for cards elsewhere in the app (Bag Summary, Manufacturing
/// Instructions, KPI cards), instead of a bare icon floating next to text.
class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.avatarSm,
      height: AppDimensions.avatarSm,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Icon(icon, color: color, size: AppDimensions.iconMd),
    );
  }
}

/// Floating bordered/shadowed filter card (matching the Artist Production
/// report's date-range filter) housing the month dropdown — its own
/// section instead of being buried inside the bar chart's card.
class _MonthFilterCard extends StatelessWidget {
  const _MonthFilterCard({required this.controller});

  final TimingReportController controller;

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
      child: Row(
        children: [
          const _SectionIcon(icon: Icons.calendar_month_rounded, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: AppDropdown<DateTime>(
              label: AppStrings.selectMonth,
              value: controller.selectedMonth.value,
              items: controller.pastYearMonths,
              itemLabel: DateTimeHelper.formatMonthYear,
              onChanged: controller.onMonthChanged,
            ),
          ),
        ],
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

/// Used vs unused minutes, summed over every day currently loaded (i.e.
/// "till date" for the selected month) as a donut chart with the used-%
/// centered inside the ring — a glanceable proportion to sit above the
/// day-by-day bar chart, which shows the same two series broken out per
/// day instead of totalled.
class _TillDateSummaryCard extends StatelessWidget {
  const _TillDateSummaryCard({required this.usedMinutes, required this.unusedMinutes});

  final int usedMinutes;
  final int unusedMinutes;

  @override
  Widget build(BuildContext context) {
    final int total = usedMinutes + unusedMinutes;
    final double usedFraction = total == 0 ? 0 : usedMinutes / total;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionIcon(icon: Icons.donut_large_rounded, color: AppColors.primary),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                AppStrings.tillDateSummary,
                style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Row(
            children: [
              SizedBox(
                width: AppDimensions.timingPieChartSize,
                height: AppDimensions.timingPieChartSize,
                child: total == 0
                    ? const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
                        child: Icon(Icons.donut_large_outlined, color: AppColors.textHint),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(AppDimensions.timingPieChartSize),
                            painter: _DonutChartPainter(
                              usedFraction: usedFraction,
                              usedColor: AppColors.success,
                              unusedColor: AppColors.chartAmber,
                              trackColor: AppColors.divider,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(usedFraction * 100).round()}%',
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                AppStrings.usedMinutes,
                                style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: AppDimensions.spacingLg),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SummaryLegendChip(
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      label: AppStrings.usedMinutes,
                      value: usedMinutes,
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    _SummaryLegendChip(
                      icon: Icons.hourglass_empty_rounded,
                      color: AppColors.chartAmber,
                      label: AppStrings.unusedMinutes,
                      value: unusedMinutes,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Icon-badge chip (matching the same recipe used for Bag Summary /
/// Manufacturing Instructions chips elsewhere in the app) instead of a bare
/// colored dot + label — used specifically for this card's two totals.
class _SummaryLegendChip extends StatelessWidget {
  const _SummaryLegendChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.iconLg,
            height: AppDimensions.iconLg,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.onPrimary, size: AppDimensions.iconSm),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.4),
                ),
                Text(
                  '$value min',
                  style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.usedFraction,
    required this.usedColor,
    required this.unusedColor,
    required this.trackColor,
  });

  final double usedFraction;
  final Color usedColor;
  final Color unusedColor;
  final Color trackColor;

  static const double _strokeWidth = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - _strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final double usedSweep = 2 * math.pi * usedFraction;
    if (usedFraction > 0) {
      final Paint usedPaint = Paint()
        ..color = usedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, usedSweep, false, usedPaint);
    }

    if (usedFraction < 1) {
      final Paint unusedPaint = Paint()
        ..color = unusedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2 + usedSweep, (2 * math.pi) - usedSweep, false, unusedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.usedFraction != usedFraction ||
      oldDelegate.usedColor != usedColor ||
      oldDelegate.unusedColor != unusedColor ||
      oldDelegate.trackColor != trackColor;
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
