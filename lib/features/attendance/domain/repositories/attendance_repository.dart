import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/attendance_summary_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceSummaryEntity>> getMonthlyAttendance({
    required String empCd,
    required DateTime month,
  });
}
