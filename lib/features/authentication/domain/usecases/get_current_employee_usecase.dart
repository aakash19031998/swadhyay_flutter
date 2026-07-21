import '../entities/employee_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentEmployeeUseCase {
  const GetCurrentEmployeeUseCase(this._repository);

  final AuthRepository _repository;

  Future<EmployeeEntity?> call() => _repository.currentEmployee();
}
