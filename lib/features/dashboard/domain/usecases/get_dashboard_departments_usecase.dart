import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_department_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDepartmentsUseCase {
  const GetDashboardDepartmentsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<DashboardDepartmentEntity>>> call() =>
      _repository.getDepartments();
}
