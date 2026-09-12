import 'attendance_day_entity.dart';

/// One month's worth of [AttendanceDayEntity] rows plus the pre-aggregated
/// stat-card totals shown above the table — computed once by whichever data
/// source builds this (mock today, a real endpoint later) rather than
/// re-derived by the UI on every rebuild.
class AttendanceSummaryEntity {
  const AttendanceSummaryEntity({
    required this.month,
    required this.days,
    required this.workingDays,
    required this.presentDays,
    required this.lateMarks,
    required this.approvedLeaves,
    required this.pendingUnapproved,
    required this.loggedHrs,
    required this.otHrs,
  });

  /// Day/time components are meaningless — only year/month matter.
  final DateTime month;

  /// One entry per calendar day of [month], in date order.
  final List<AttendanceDayEntity> days;

  final int workingDays;
  final int presentDays;
  final int lateMarks;
  final int approvedLeaves;
  final int pendingUnapproved;
  final double loggedHrs;
  final double otHrs;
}
