import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_check_entity.dart';
import '../repositories/qc_check_repository.dart';

class GetQcChecksUseCase {
  const GetQcChecksUseCase(this._repository);

  final QcCheckRepository _repository;

  Future<Either<Failure, List<QcCheckEntity>>> call({String query = ''}) {
    return _repository.getChecks(query: query);
  }
}
