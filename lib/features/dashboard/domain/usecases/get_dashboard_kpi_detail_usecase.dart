import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_kpi_detail_entity.dart';
import '../entities/dashboard_kpi_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardKpiDetailUseCase {
  const GetDashboardKpiDetailUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, DashboardKpiDetailEntity>> call({
    required String departmentId,
    required DashboardKpiKind kind,
  }) => _repository.getKpiDetail(departmentId: departmentId, kind: kind);
}
