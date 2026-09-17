import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/earn_till_date_entity.dart';
import '../repositories/earn_till_date_repository.dart';

class GetEarnTillDateUseCase {
  const GetEarnTillDateUseCase(this._repository);

  final EarnTillDateRepository _repository;

  Future<Either<Failure, EarnTillDateEntity>> call({
    required String empCd,
    required String empName,
  }) => _repository.getEarnTillDate(empCd: empCd, empName: empName);
}
