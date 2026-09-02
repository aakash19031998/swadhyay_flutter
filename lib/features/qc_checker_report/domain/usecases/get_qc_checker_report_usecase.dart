import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_checker_report_entity.dart';
import '../repositories/qc_checker_report_repository.dart';

class GetQcCheckerReportUseCase {
  const GetQcCheckerReportUseCase(this._repository);

  final QcCheckerReportRepository _repository;

  Future<Either<Failure, QcCheckerReportEntity>> call({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  }) {
    return _repository.getReport(
      fromDate: fromDate,
      toDate: toDate,
      empCd: empCd,
    );
  }
}
