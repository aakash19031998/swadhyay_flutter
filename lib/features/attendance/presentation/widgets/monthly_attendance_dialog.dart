import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_modern_dropdown.dart';
import '../../../../core/widgets/bordered_surface_card.dart';
import '../../../../core/widgets/report_table.dart';
import '../../domain/entities/attendance_day_entity.dart';
import '../../domain/entities/attendance_summary_entity.dart';
import '../../domain/usecases/get_monthly_attendance_usecase.dart';

/// "Monthly Attendance Detailed Record" — opened from Profile's "In Time"
/// tile. Stat cards + a filterable/monthly day-by-day table, all backed by
/// [GetMonthlyAttendanceUseCase] (placeholder data today — see
/// `AttendanceDataSource`'s own doc comment; a real endpoint later is a
/// one-line swap in [ProfileBinding], same as every other mock feature in
/// this app).
class MonthlyAttendanceDialog extends StatefulWidget {
  const MonthlyAttendanceDialog({
    required this.empCd,
    required this.empName,
    super.key,
  });

  final String empCd;
  final String empName;

  static Future<void> show({required String empCd, required String empName}) {
    return Get.dialog(MonthlyAttendanceDialog(empCd: empCd, empName: empName));
  }

  @override
  State<MonthlyAttendanceDialog> createState() =>
      _MonthlyAttendanceDialogState();
}

enum _AttendanceTab { all, present, leaves, weekends }

class _MonthlyAttendanceDialogState extends State<MonthlyAttendanceDialog> {
  final DateTime _now = DateTime.now();
  late DateTime _selectedMonth = DateTime(_now.year, _now.month);
  _AttendanceTab _selectedTab = _AttendanceTab.all;

  AttendanceSummaryEntity? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  List<DateTime> get _pastYearMonths =>
      List.generate(12, (i) => DateTime(_now.year, _now.month - i));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Guards against ever leaving [_isLoading] stuck `true` (an
    // indefinitely-spinning dialog) if `Get.find` or the use case itself
    // throws for any reason instead of returning a `Left` failure.
    try {
      final result = await Get.find<GetMonthlyAttendanceUseCase>()(
        empCd: widget.empCd,
        month: _selectedMonth,
      );
      if (!mounted) return;
      result.fold(
        (failure) => setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        }),
        (data) => setState(() {
          _summary = data;
          _isLoading = false;
          _selectedTab = _AttendanceTab.all;
        }),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppStrings.somethingWentWrong;
        _isLoading = false;
      });
    }
  }

  void _onMonthChanged(DateTime? month) {
    if (month == null || month == _selectedMonth) return;
    setState(() => _selectedMonth = month);
    _load();
  }

  List<AttendanceDayEntity> _filteredDays(AttendanceSummaryEntity summary) {
    switch (_selectedTab) {
      case _AttendanceTab.all:
        return summary.days;
      case _AttendanceTab.present:
        return [
          for (final day in summary.days)
            if (day.status == AttendanceDayStatus.present) day,
        ];
      case _AttendanceTab.leaves:
        return [
          for (final day in summary.days)
            if (day.status == AttendanceDayStatus.leave) day,
        ];
      case _AttendanceTab.weekends:
        return [
          for (final day in summary.days)
            if (day.status == AttendanceDayStatus.weeklyOff ||
                day.status == AttendanceDayStatus.holiday)
              day,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double dialogHeight = (screenSize.height * 0.9).clamp(420, 760);
    // Wider than the QC action dialog's own "wide" variant — this table has
    // 8 columns (vs. a 2-column repair checklist) and needs the room.
    final double dialogWidth = (screenSize.width * 0.98).clamp(0, 1280);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      insetPadding: const EdgeInsets.all(AppDimensions.spacingSm),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minHeight: dialogHeight,
          maxHeight: dialogHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                empName: widget.empName,
                empCd: widget.empCd,
                month: _selectedMonth,
                pastYearMonths: _pastYearMonths,
                onMonthChanged: _onMonthChanged,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    final String? error = _errorMessage;
    if (error != null) {
      return Center(
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final AttendanceSummaryEntity summary = _summary!;
    final List<AttendanceDayEntity> filteredDays = _filteredDays(summary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatsRow(summary: summary),
        const SizedBox(height: AppDimensions.spacingMd),
        _TabsRow(
          summary: summary,
          selected: _selectedTab,
          onSelected: (tab) => setState(() => _selectedTab = tab),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(child: _AttendanceTable(days: filteredDays)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.empName,
    required this.empCd,
    required this.month,
    required this.pastYearMonths,
    required this.onMonthChanged,
  });

  final String empName;
  final String empCd;
  final DateTime month;
  final List<DateTime> pastYearMonths;
  final ValueChanged<DateTime?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimensions.avatarSm,
          height: AppDimensions.avatarSm,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.monthlyAttendanceTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$empName (Emp ID: $empCd) • ${DateTimeHelper.formatMonthYear(month)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        SizedBox(
          width: 260,
          child: AppModernDropdown<DateTime>(
            label: AppStrings.selectMonth,
            icon: Icons.calendar_today_outlined,
            value: month,
            items: pastYearMonths,
            itemLabel: DateTimeHelper.formatMonthYear,
            onChanged: onMonthChanged,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});

  final AttendanceSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    String days(int count) => count == 1 ? 'Day' : AppStrings.daySuffix;

    final List<Widget> cards = [
      _StatCard(
        icon: Icons.event_available_rounded,
        title: AppStrings.workingDays,
        value: '${summary.workingDays}',
        valueSuffix: days(summary.workingDays),
        color: AppColors.primary,
        containerColor: AppColors.primaryContainer,
      ),
      _StatCard(
        icon: Icons.check_circle_outline_rounded,
        title: AppStrings.presentDaysStat,
        value: '${summary.presentDays}',
        valueSuffix: days(summary.presentDays),
        color: AppColors.success,
        containerColor: AppColors.successContainer,
      ),
      _StatCard(
        icon: Icons.schedule_rounded,
        title: AppStrings.lateMarks,
        value: '${summary.lateMarks}',
        valueSuffix: '(>09:30)',
        color: AppColors.warning,
        containerColor: AppColors.warningContainer,
      ),
      _StatCard(
        icon: Icons.beach_access_outlined,
        title: AppStrings.approvedLeaves,
        value: '${summary.approvedLeaves}',
        valueSuffix: '${days(summary.approvedLeaves)} (Paid)',
        color: AppColors.info,
        containerColor: AppColors.infoContainer,
      ),
      _StatCard(
        icon: Icons.error_outline_rounded,
        title: AppStrings.pendingUnapproved,
        value: '${summary.pendingUnapproved}',
        valueSuffix: days(summary.pendingUnapproved),
        color: AppColors.error,
        containerColor: AppColors.errorContainer,
      ),
      _StatCard(
        icon: Icons.timelapse_rounded,
        title: AppStrings.loggedHrsOt,
        value:
            '${summary.loggedHrs.toStringAsFixed(1)} / ${summary.otHrs.toStringAsFixed(1)}',
        valueSuffix: 'hrs',
        color: AppColors.textPrimary,
        containerColor: AppColors.surfaceVariant,
      ),
    ];

    // A plain responsive row (all 6 side by side on tablet, stacked on
    // phone) rather than `KpiRow` — `KpiRow` wraps its cards in an `Obx`,
    // which GetX treats as a misuse (throwing "improper use of a GetX")
    // when the card list underneath never reads a reactive `Rx` variable,
    // exactly the case here since this dialog's state is plain `setState`.
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
  }
}

/// A deliberately compact stat card — tighter padding/icon size than the
/// shared `KpiCard`, and its value/suffix stacked on separate lines instead
/// of side by side on one baseline — so all 6 of these fit on a single row
/// without truncating/overflowing (KpiCard's own roomier layout is sized
/// for 3-4 cards per row, not 6).
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.containerColor,
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: AppDimensions.spacingXxs),
                Flexible(
                  child: Text(
                    valueSuffix!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TabsRow extends StatelessWidget {
  const _TabsRow({
    required this.summary,
    required this.selected,
    required this.onSelected,
  });

  final AttendanceSummaryEntity summary;
  final _AttendanceTab selected;
  final ValueChanged<_AttendanceTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final int presentCount = summary.days
        .where((d) => d.status == AttendanceDayStatus.present)
        .length;
    final int leaveCount = summary.days
        .where((d) => d.status == AttendanceDayStatus.leave)
        .length;
    final int weekendCount = summary.days
        .where(
          (d) =>
              d.status == AttendanceDayStatus.weeklyOff ||
              d.status == AttendanceDayStatus.holiday,
        )
        .length;

    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterChip(
          label: '${AppStrings.attendanceTabAll} (${summary.days.length})',
          selected: selected == _AttendanceTab.all,
          onTap: () => onSelected(_AttendanceTab.all),
        ),
        _FilterChip(
          label: '${AppStrings.attendanceTabPresent} ($presentCount)',
          selected: selected == _AttendanceTab.present,
          onTap: () => onSelected(_AttendanceTab.present),
        ),
        _FilterChip(
          label: '${AppStrings.attendanceTabLeaves} ($leaveCount)',
          selected: selected == _AttendanceTab.leaves,
          onTap: () => onSelected(_AttendanceTab.leaves),
        ),
        _FilterChip(
          label: '${AppStrings.attendanceTabWeekends} ($weekendCount)',
          selected: selected == _AttendanceTab.weekends,
          onTap: () => onSelected(_AttendanceTab.weekends),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  const _AttendanceTable({required this.days});

  final List<AttendanceDayEntity> days;

  @override
  Widget build(BuildContext context) {
    return BorderedSurfaceCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: ReportTable(
          columns: const [
            ReportHeaderLabel(AppStrings.dateAndDayColumn),
            ReportHeaderLabel(AppStrings.statusColumn),
            ReportHeaderLabel(AppStrings.inTimeColumn),
            ReportHeaderLabel(AppStrings.outTimeColumn),
            ReportHeaderLabel(AppStrings.totalHrsColumn),
            ReportHeaderLabel(AppStrings.otHrsColumn),
            ReportHeaderLabel(AppStrings.leaveTypeReasonColumn),
            ReportHeaderLabel(AppStrings.approvalStatusColumn),
          ],
          rows: [for (final day in days) _buildRow(context, day)],
        ),
      ),
    );
  }

  List<Widget> _buildRow(BuildContext context, AttendanceDayEntity day) {
    return [
      _DateDayCell(day: day),
      _StatusPill(status: day.status),
      _InTimeCell(day: day),
      ReportValueCell(
        text: day.isOngoing ? AppStrings.inProgress : (day.outTime ?? '-'),
      ),
      ReportValueCell(
        text: day.status == AttendanceDayStatus.present
            ? '${day.totalHrs.toStringAsFixed(day.isOngoing ? 1 : 2)}'
                  '${day.isOngoing ? ' ${AppStrings.ongoingSuffix}' : ''}'
            : '0.0',
      ),
      ReportValueCell(
        text: day.status == AttendanceDayStatus.present
            ? day.otHrs.toStringAsFixed(2)
            : '0.0',
      ),
      _LeaveCell(day: day),
      _ApprovalCell(day: day),
    ];
  }
}

class _DateDayCell extends StatelessWidget {
  const _DateDayCell({required this.day});

  final AttendanceDayEntity day;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateTimeHelper.formatDate(day.date),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          DateTimeHelper.formatWeekday(day.date),
          style: textTheme.labelSmall?.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final AttendanceDayStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color, Color background) = switch (status) {
      AttendanceDayStatus.present => (
        AppStrings.statusPresent,
        AppColors.success,
        AppColors.successContainer,
      ),
      AttendanceDayStatus.leave => (
        AppStrings.statusLeave,
        AppColors.error,
        AppColors.errorContainer,
      ),
      AttendanceDayStatus.weeklyOff => (
        AppStrings.statusWeeklyOff,
        AppColors.textSecondary,
        AppColors.surfaceVariant,
      ),
      AttendanceDayStatus.holiday => (
        AppStrings.statusHoliday,
        AppColors.info,
        AppColors.infoContainer,
      ),
      AttendanceDayStatus.notMarked => (
        '-',
        AppColors.textHint,
        Colors.transparent,
      ),
    };

    if (status == AttendanceDayStatus.notMarked) {
      return Text(
        '-',
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InTimeCell extends StatelessWidget {
  const _InTimeCell({required this.day});

  final AttendanceDayEntity day;

  @override
  Widget build(BuildContext context) {
    if (day.status != AttendanceDayStatus.present || day.inTime == null) {
      return const ReportValueCell(text: '-');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.isLate ? AppColors.warning : AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXxs),
        Text(day.inTime!, style: Theme.of(context).textTheme.bodyMedium),
        if (day.isLate) ...[
          const SizedBox(width: AppDimensions.spacingXxs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: Text(
              AppStrings.lateBadge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LeaveCell extends StatelessWidget {
  const _LeaveCell({required this.day});

  final AttendanceDayEntity day;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (day.status == AttendanceDayStatus.weeklyOff) {
      return ReportValueCell(
        text: AppStrings.statusWeeklyOff,
        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      );
    }
    if (day.status == AttendanceDayStatus.holiday) {
      return ReportValueCell(
        text: AppStrings.statusHoliday,
        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      );
    }
    if (day.status != AttendanceDayStatus.leave) {
      return const ReportValueCell(text: '-');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.leaveType ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (day.leaveReason != null)
          Text(
            day.leaveReason!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(color: AppColors.textHint),
          ),
      ],
    );
  }
}

class _ApprovalCell extends StatelessWidget {
  const _ApprovalCell({required this.day});

  final AttendanceDayEntity day;

  @override
  Widget build(BuildContext context) {
    if (day.status != AttendanceDayStatus.leave) {
      return const ReportValueCell(text: '-');
    }

    final (
      String label,
      Color color,
      Color background,
    ) = switch (day.approvalStatus) {
      AttendanceApprovalStatus.approved => (
        AppStrings.approvalApproved,
        AppColors.success,
        AppColors.successContainer,
      ),
      AttendanceApprovalStatus.rejected => (
        AppStrings.approvalRejected,
        AppColors.error,
        AppColors.errorContainer,
      ),
      AttendanceApprovalStatus.pending => (
        AppStrings.approvalPending,
        AppColors.warning,
        AppColors.warningContainer,
      ),
      AttendanceApprovalStatus.notApplicable => (
        '-',
        AppColors.textHint,
        Colors.transparent,
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (day.approvalNote != null)
          Text(
            day.approvalNote!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
          ),
      ],
    );
  }
}
