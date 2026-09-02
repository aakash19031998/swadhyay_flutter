import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/hk_loader_card.dart';
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
            const _TopBar(),
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
                    _FilterCard(controller: controller),
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
                            _SummaryKpiRow(controller: controller),
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

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.onPrimary,
              ),
              onPressed: Get.back,
            ),
            Text(
              AppStrings.qcCheckerReportTitle,
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

/// Date-range filter as its own floating card — identical shape/behavior to
/// `ArtistProductionView`'s own `_FilterCard`.
class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.controller});

  final QcCheckerReportController controller;

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
          final bool isTablet =
              constraints.maxWidth >= AppDimensions.breakpointPhone;

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
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;

  /// Null when To date has been cleared after a From date change — the
  /// user must tap through and pick a new one before Show will run.
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: AppDimensions.iconSm,
          ),
        ),
        child: Text(
          date != null
              ? DateTimeHelper.formatDate(date!)
              : AppStrings.selectDate,
          style: date == null
              ? TextStyle(color: Theme.of(context).hintColor)
              : null,
        ),
      ),
    );
  }
}

/// Total Points / Total Bags / Repairs Caught / Own Repair Offset, at a
/// glance above the two tables — side by side on tablet width, stacked on
/// phone (same responsive shape as `ArtistProductionView`'s own `_KpiRow`).
class _SummaryKpiRow extends StatelessWidget {
  const _SummaryKpiRow({required this.controller});

  final QcCheckerReportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Widget> cards = [
        _SummaryKpiCard(
          icon: Icons.military_tech_outlined,
          label: AppStrings.totalPoints,
          value: controller.totalPointsValue.value.toStringAsFixed(2),
          color: AppColors.textPrimary,
          containerColor: AppColors.primaryContainer,
        ),
        _SummaryKpiCard(
          icon: Icons.inventory_2_outlined,
          label: AppStrings.totalBagsUnits,
          value: '${controller.totalBagPieces.value}',
          color: AppColors.info,
          containerColor: AppColors.infoContainer,
        ),
        _SummaryKpiCard(
          icon: Icons.done_all_rounded,
          label: AppStrings.repairsCaught,
          value: '${controller.totalRepairCaught.value}',
          color: AppColors.success,
          containerColor: AppColors.successContainer,
        ),
        _SummaryKpiCard(
          icon: Icons.warning_amber_rounded,
          label: AppStrings.ownRepairOffset,
          value: controller.ownRepairPoints.value.toStringAsFixed(2),
          valueSuffix: '(${controller.ownRepairBags.value} bags)',
          color: AppColors.error,
          containerColor: AppColors.errorContainer,
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet =
              constraints.maxWidth >= AppDimensions.breakpointPhone;

          if (!isTablet) {
            return Column(
              children: [
                for (final card in cards) ...[
                  card,
                  if (card != cards.last)
                    const SizedBox(height: AppDimensions.spacingSm),
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

/// Same shape as `ArtistProductionView`'s own `_KpiCard` — icon-left square
/// badge, uppercase label + big bold value stacked to its right, no
/// subtitle line.
class _SummaryKpiCard extends StatelessWidget {
  const _SummaryKpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.containerColor,
    this.valueSuffix,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? valueSuffix;
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
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
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
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    if (valueSuffix != null) ...[
                      const SizedBox(width: AppDimensions.spacingXs),
                      Text(
                        valueSuffix!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: color.withValues(alpha: 0.7),
                        ),
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

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.onPrimary,
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

/// Generic gradient-header/zebra-row table — same visual language as
/// `ArtistProductionView`'s own `_ReportTable`, but cells are full [Widget]s
/// (not just strings) so a column can hold a [_ProcessBadge] instead of
/// plain text, and an optional [footer] renders as the table's last row
/// (e.g. a total-points bar) inside the same rounded/clipped block.
class _ReportTable extends StatefulWidget {
  const _ReportTable({
    required this.columns,
    required this.rows,
    this.footer,
    this.fillHeight = true,
  });

  final List<Widget> columns;
  final List<List<Widget>> rows;
  final Widget? footer;

  /// `true` (Prediction Score Matrix): rows fill whatever height the card
  /// is given and scroll internally, so a long list never pushes [footer]
  /// off-screen. `false` (Shift & Process Distribution — typically only a
  /// handful of rows): the table wraps its own content height instead,
  /// same as `ArtistProductionView`'s own tables, so the card doesn't get
  /// stretched to match its sibling and leave dead space below its rows.
  final bool fillHeight;

  @override
  State<_ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<_ReportTable> {
  // Explicit controller (rather than letting `Scrollbar` auto-detect the
  // nearest `Scrollable`) so the thumb reliably attaches to *this* table's
  // own row list — auto-detection is fragile once a table like this sits
  // inside other scrollables/rebuilding ancestors.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> columns = widget.columns;
    final List<List<Widget>> rows = widget.rows;
    final Widget? footer = widget.footer;
    final bool fillHeight = widget.fillHeight;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<Widget> rowWidgets = [
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
                  Expanded(child: Center(child: cell)),
              ],
            ),
          ),
        ),
    ];

    return Column(
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          child: Row(
            children: [for (final column in columns) Expanded(child: column)],
          ),
        ),
        if (rows.isEmpty)
          fillHeight
              ? Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.noDataFound,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: Text(
                    AppStrings.noDataFound,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                )
        else if (!fillHeight)
          // Wraps its own content height — no forced fill, no internal
          // scroll — same as `ArtistProductionView`'s own tables.
          Column(children: rowWidgets)
        else
          // `Expanded` + internal scroll (rather than a fixed height cap)
          // so the rows fill whatever space the card is actually given —
          // [footer] (e.g. the "Total Points" bar) stays pinned right
          // below them instead of needing a further page-scroll to reach.
          Expanded(
            // `thumbVisibility: true` keeps the thumb drawn (not just a
            // transient fade-in on drag) — but only when the rows
            // actually overflow the available height; a short list that
            // fits with no scrolling paints no thumb at all regardless.
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(children: rowWidgets),
              ),
            ),
          ),
        ?footer,
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
          child: _ReportTable(
            columns: const [
              _HeaderLabel(AppStrings.qcProcess),
              _HeaderLabel(AppStrings.qcPrediction),
              _HeaderLabel(AppStrings.totalPoints),
              _HeaderLabel(AppStrings.repairCaught),
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
              child: _ReportTable(
                fillHeight: false,
                columns: const [
                  _HeaderLabel(AppStrings.qcProcess),
                  _HeaderLabel(AppStrings.bagPieces),
                  _HeaderLabel(AppStrings.points),
                  _HeaderLabel(AppStrings.repair),
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
