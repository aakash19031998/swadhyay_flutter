import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/attendance_summary_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dataSource);

  final AttendanceDataSource _dataSource;

  @override
  Future<Either<Failure, AttendanceSummaryEntity>> getMonthlyAttendance({
    required String empCd,
    required DateTime month,
  }) {
    return guard(
      () => _dataSource.getMonthlyAttendance(empCd: empCd, month: month),
    );
  }
}
