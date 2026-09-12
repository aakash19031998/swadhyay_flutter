import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/dashboard_department_entity.dart';
import '../../domain/entities/dashboard_kpi_detail_entity.dart';
import '../../domain/entities/dashboard_kpi_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dataSource);

  final DashboardDataSource _dataSource;

  @override
  Future<Either<Failure, List<DashboardDepartmentEntity>>> getDepartments() {
    return guard(() => _dataSource.getDepartments());
  }

  @override
  Future<Either<Failure, DashboardSummaryEntity>> getSummary({
    required String departmentId,
  }) {
    return guard(() => _dataSource.getSummary(departmentId: departmentId));
  }

  @override
  Future<Either<Failure, DashboardKpiDetailEntity>> getKpiDetail({
    required String departmentId,
    required DashboardKpiKind kind,
  }) {
    return guard(
      () => _dataSource.getKpiDetail(departmentId: departmentId, kind: kind),
    );
  }
}
