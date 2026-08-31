import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_checker_department_list_entity.dart';
import '../repositories/qc_checker_department_repository.dart';

class GetQcCheckerDepartmentsUseCase {
  const GetQcCheckerDepartmentsUseCase(this._repository);

  final QcCheckerDepartmentRepository _repository;

  Future<Either<Failure, QcCheckerDepartmentListEntity>> call({
    required String empCd,
  }) {
    return _repository.getDepartments(empCd: empCd);
  }
}
