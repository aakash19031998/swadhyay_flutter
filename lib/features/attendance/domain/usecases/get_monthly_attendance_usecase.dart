import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/attendance_summary_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMonthlyAttendanceUseCase {
  const GetMonthlyAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<Either<Failure, AttendanceSummaryEntity>> call({
    required String empCd,
    required DateTime month,
  }) => _repository.getMonthlyAttendance(empCd: empCd, month: month);
}
