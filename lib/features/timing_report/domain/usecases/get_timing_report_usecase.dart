import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/timing_report_entity.dart';
import '../repositories/timing_report_repository.dart';

class GetTimingReportUseCase {
  const GetTimingReportUseCase(this._repository);

  final TimingReportRepository _repository;

  Future<Either<Failure, List<TimingReportEntity>>> call({
    required int year,
    required int month,
  }) {
    return _repository.getReport(year: year, month: month);
  }
}
