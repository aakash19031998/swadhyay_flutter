import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/timing_report_entity.dart';
import '../../domain/repositories/timing_report_repository.dart';
import '../datasources/timing_report_data_source.dart';

class TimingReportRepositoryImpl implements TimingReportRepository {
  TimingReportRepositoryImpl(this._dataSource);

  final TimingReportDataSource _dataSource;

  @override
  Future<Either<Failure, List<TimingReportEntity>>> getReport({required String empCd}) {
    return guard(() async {
      final entries = await _dataSource.getReport(empCd: empCd);
      return entries;
    });
  }
}
