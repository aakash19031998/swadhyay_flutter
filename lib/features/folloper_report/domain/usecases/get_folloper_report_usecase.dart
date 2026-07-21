import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/folloper_report_entity.dart';
import '../repositories/folloper_report_repository.dart';

class GetFolloperReportUseCase {
  const GetFolloperReportUseCase(this._repository);

  final FolloperReportRepository _repository;

  Future<Either<Failure, List<FolloperReportEntity>>> call({String query = ''}) {
    return _repository.getReport(query: query);
  }
}
