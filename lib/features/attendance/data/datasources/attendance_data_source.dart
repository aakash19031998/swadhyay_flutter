import '../../domain/entities/attendance_summary_entity.dart';

/// No real backend exists for this screen yet, so — same as
/// `DashboardDataSource` — this returns a domain entity directly instead of
/// a `data/models` shape parsed from JSON. Add a `data/models` layer (and a
/// real `ApiEndpoints` entry) once an actual attendance endpoint exists.
abstract class AttendanceDataSource {
  Future<AttendanceSummaryEntity> getMonthlyAttendance({
    required String empCd,
    required DateTime month,
  });
}
