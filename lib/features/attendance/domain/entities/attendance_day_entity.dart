/// One calendar day's worth of the Monthly Attendance Detailed Record.
/// [status] drives which other fields are meaningful — a [weeklyOff]/
/// [holiday]/[notMarked] day never has punch times, and only [leave] carries
/// [leaveType]/[leaveReason]/[approvalStatus].
enum AttendanceDayStatus { present, leave, weeklyOff, holiday, notMarked }

/// Only meaningful when [AttendanceDayEntity.status] is
/// [AttendanceDayStatus.leave] — [notApplicable] covers every other status.
enum AttendanceApprovalStatus { approved, rejected, pending, notApplicable }

class AttendanceDayEntity {
  const AttendanceDayEntity({
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.totalHrs = 0,
    this.otHrs = 0,
    this.isLate = false,
    this.isOngoing = false,
    this.leaveType,
    this.leaveReason,
    this.approvalStatus = AttendanceApprovalStatus.notApplicable,
    this.approvalNote,
  });

  final DateTime date;
  final AttendanceDayStatus status;

  /// Punch-in time, e.g. `09:50` — only set when [status] is [present].
  final String? inTime;

  /// Punch-out time — `null` while [isOngoing] is true (today's row, still
  /// in progress) rather than while genuinely unpunched.
  final String? outTime;
  final double totalHrs;
  final double otHrs;

  /// `true` when [inTime] is later than the shift's grace cutoff.
  final bool isLate;

  /// `true` only for today's own row when it's still mid-shift — no
  /// [outTime]/final [totalHrs] yet.
  final bool isOngoing;

  final String? leaveType;
  final String? leaveReason;
  final AttendanceApprovalStatus approvalStatus;

  /// Who actioned the leave and why, e.g. "By: Rohit Patel (Team Lead)" or
  /// "HR Desk (Medical certificate pending)".
  final String? approvalNote;
}
