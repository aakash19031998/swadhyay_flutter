import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/folloper_report_entity.dart';

abstract class FolloperReportRepository {
  Future<Either<Failure, List<FolloperReportEntity>>> getReport({String query = ''});
}
