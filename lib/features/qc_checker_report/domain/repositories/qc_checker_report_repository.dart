import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_checker_report_entity.dart';

abstract class QcCheckerReportRepository {
  Future<Either<Failure, QcCheckerReportEntity>> getReport({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  });
}
