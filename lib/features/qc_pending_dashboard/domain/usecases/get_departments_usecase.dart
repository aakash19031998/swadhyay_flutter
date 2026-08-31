import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_department_list_entity.dart';
import '../repositories/qc_check_repository.dart';

class GetDepartmentsUseCase {
  const GetDepartmentsUseCase(this._repository);

  final QcCheckRepository _repository;

  Future<Either<Failure, QcDepartmentListEntity>> call({required String empCd}) {
    return _repository.getDepartments(empCd: empCd);
  }
}
