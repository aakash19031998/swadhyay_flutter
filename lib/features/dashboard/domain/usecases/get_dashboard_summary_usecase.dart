import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_summary_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, DashboardSummaryEntity>> call({
    required String departmentId,
  }) => _repository.getSummary(departmentId: departmentId);
}
