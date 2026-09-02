import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/qc_checker_report_entity.dart';
import '../../domain/repositories/qc_checker_report_repository.dart';
import '../datasources/qc_checker_report_data_source.dart';

class QcCheckerReportRepositoryImpl implements QcCheckerReportRepository {
  QcCheckerReportRepositoryImpl(this._dataSource);

  final QcCheckerReportDataSource _dataSource;

  @override
  Future<Either<Failure, QcCheckerReportEntity>> getReport({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  }) {
    return guard(() async {
      final QcCheckerReportEntity report = await _dataSource.getReport(
        fromDate: fromDate,
        toDate: toDate,
        empCd: empCd,
      );
      return report;
    });
  }
}
