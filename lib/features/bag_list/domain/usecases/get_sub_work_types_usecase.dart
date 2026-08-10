import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/sub_work_type_entity.dart';
import '../repositories/sub_work_type_repository.dart';

class GetSubWorkTypesUseCase {
  const GetSubWorkTypesUseCase(this._repository);

  final SubWorkTypeRepository _repository;

  Future<Either<Failure, List<SubWorkTypeEntity>>> call({
    required String schr,
    required String workType,
    required String empCd,
  }) {
    return _repository.getSubWorkTypes(schr: schr, workType: workType, empCd: empCd);
  }
}
