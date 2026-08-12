import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/timing_report_entity.dart';

abstract class TimingReportRepository {
  Future<Either<Failure, List<TimingReportEntity>>> getReport({required String empCd});
}
