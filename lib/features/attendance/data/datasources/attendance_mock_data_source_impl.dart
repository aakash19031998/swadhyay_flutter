import 'dart:math';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/attendance_day_entity.dart';
import '../../domain/entities/attendance_summary_entity.dart';
import 'attendance_data_source.dart';

/// Placeholder data only — no backend endpoint exists for this screen yet
/// (see [AttendanceDataSource]'s own doc comment). Deterministically
/// generates a full calendar month of attendance rows from [empCd]/[month]
/// (same seed always produces the same numbers, so switching away from and
/// back to a month doesn't visibly "reshuffle" it), backfilling every day up
/// to today (for the current month) or the whole month (for a past one) —
/// any day after that stays [AttendanceDayStatus.notMarked] since it hasn't
/// happened yet.
class AttendanceMockDataSourceImpl implements AttendanceDataSource {
  @override
  Future<AttendanceSummaryEntity> getMonthlyAttendance({
    required String empCd,
    required DateTime month,
  }) async {
    await Future.delayed(AppConfig.mockLatency);

    final DateTime now = DateTime.now();
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final bool isCurrentMonth =
        month.year == now.year && month.month == now.month;
    final bool isFutureMonth = DateTime(
      month.year,
      month.month,
    ).isAfter(DateTime(now.year, now.month));
    final int lastElapsedDay = isFutureMonth
        ? 0
        : (isCurrentMonth ? now.day : daysInMonth);

    final Random random = Random(
      empCd.hashCode ^ (month.year * 100 + month.month),
    );

    // Exactly two leave days (one approved, one not) among this month's
    // already-elapsed weekdays — picked up front so the KPI totals below
    // stay consistent with what the table actually shows, rather than
    // relying on a per-day dice roll that could land on zero or five.
    final List<int> elapsedWeekdays = [
      for (int day = 1; day <= lastElapsedDay; day++)
        if (DateTime(month.year, month.month, day).weekday != DateTime.sunday)
          day,
    ];
    final Set<int> leaveDays = {};
    if (elapsedWeekdays.length >= 4) {
      leaveDays.add(elapsedWeekdays[elapsedWeekdays.length - 3]);
      leaveDays.add(elapsedWeekdays[elapsedWeekdays.length - 5]);
    } else if (elapsedWeekdays.isNotEmpty) {
      leaveDays.add(elapsedWeekdays.last);
    }

    // One declared holiday mid-month, distinct from the weekly Sunday off —
    // only if that date isn't already a leave day.
    final int? holidayDay =
        (daysInMonth >= 15 &&
            DateTime(month.year, month.month, 15).weekday != DateTime.sunday)
        ? 15
        : null;

    final List<AttendanceDayEntity> days = [];
    int lateMarks = 0;
    int approvedLeaves = 0;
    int pendingUnapproved = 0;
    double loggedHrs = 0;
    double otHrs = 0;
    int presentDays = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(month.year, month.month, day);

      if (day > lastElapsedDay) {
        days.add(
          AttendanceDayEntity(
            date: date,
            status: AttendanceDayStatus.notMarked,
          ),
        );
        continue;
      }

      if (date.weekday == DateTime.sunday) {
        days.add(
          AttendanceDayEntity(
            date: date,
            status: AttendanceDayStatus.weeklyOff,
          ),
        );
        continue;
      }

      if (day == holidayDay && !leaveDays.contains(day)) {
        days.add(
          AttendanceDayEntity(date: date, status: AttendanceDayStatus.holiday),
        );
        continue;
      }

      if (leaveDays.contains(day)) {
        final bool approved = day == leaveDays.first;
        if (approved) {
          approvedLeaves++;
        } else {
          pendingUnapproved++;
        }
        days.add(
          AttendanceDayEntity(
            date: date,
            status: AttendanceDayStatus.leave,
            leaveType: approved ? 'Casual Leave (CL)' : 'Sick Leave (SL)',
            leaveReason: approved
                ? 'Personal urgent family commitment'
                : 'Severe viral flu and medical rest required',
            approvalStatus: approved
                ? AttendanceApprovalStatus.approved
                : AttendanceApprovalStatus.rejected,
            approvalNote: approved
                ? 'By: Rohit Patel (Team Lead)'
                : 'HR Desk (Medical certificate pending)',
          ),
        );
        continue;
      }

      // Present — a mostly-on-time 09:00-09:25 punch-in, with roughly a
      // 15% chance (seeded, so stable per employee/month) of a >09:30 late
      // punch-in instead.
      final bool isLate = random.nextInt(100) < 15;
      final int inMinuteOffset = isLate
          ? 31 + random.nextInt(25)
          : random.nextInt(26);
      final int inHour = 9 + (inMinuteOffset ~/ 60);
      final int inMinute = inMinuteOffset % 60;
      if (isLate) lateMarks++;
      presentDays++;

      final bool isToday = isCurrentMonth && day == now.day;
      if (isToday) {
        final Duration worked = now.difference(
          DateTime(date.year, date.month, date.day, inHour, inMinute),
        );
        final double hrs = (worked.inMinutes / 60).clamp(0, 24);
        loggedHrs += hrs;
        days.add(
          AttendanceDayEntity(
            date: date,
            status: AttendanceDayStatus.present,
            inTime:
                '${inHour.toString().padLeft(2, '0')}:${inMinute.toString().padLeft(2, '0')}',
            isLate: isLate,
            isOngoing: true,
            totalHrs: double.parse(hrs.toStringAsFixed(1)),
          ),
        );
        continue;
      }

      final int workedMinutes = 480 + random.nextInt(90);
      final double hrs = workedMinutes / 60;
      final double ot = hrs > 8.5
          ? double.parse((hrs - 8.5).toStringAsFixed(2))
          : 0;
      final DateTime outAt = DateTime(
        date.year,
        date.month,
        date.day,
        inHour,
        inMinute,
      ).add(Duration(minutes: workedMinutes));
      loggedHrs += hrs;
      otHrs += ot;
      days.add(
        AttendanceDayEntity(
          date: date,
          status: AttendanceDayStatus.present,
          inTime:
              '${inHour.toString().padLeft(2, '0')}:${inMinute.toString().padLeft(2, '0')}',
          outTime:
              '${outAt.hour.toString().padLeft(2, '0')}:${outAt.minute.toString().padLeft(2, '0')}',
          isLate: isLate,
          totalHrs: double.parse(hrs.toStringAsFixed(2)),
          otHrs: ot,
        ),
      );
    }

    final int workingDays = [
      for (int day = 1; day <= daysInMonth; day++)
        if (DateTime(month.year, month.month, day).weekday != DateTime.sunday &&
            day != holidayDay)
          day,
    ].length;

    return AttendanceSummaryEntity(
      month: month,
      days: days,
      workingDays: workingDays,
      presentDays: presentDays,
      lateMarks: lateMarks,
      approvedLeaves: approvedLeaves,
      pendingUnapproved: pendingUnapproved,
      loggedHrs: double.parse(loggedHrs.toStringAsFixed(1)),
      otHrs: double.parse(otHrs.toStringAsFixed(1)),
    );
  }
}
