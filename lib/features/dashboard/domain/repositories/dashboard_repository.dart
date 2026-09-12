import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_department_entity.dart';
import '../entities/dashboard_kpi_detail_entity.dart';
import '../entities/dashboard_kpi_entity.dart';
import '../entities/dashboard_summary_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<DashboardDepartmentEntity>>> getDepartments();

  Future<Either<Failure, DashboardSummaryEntity>> getSummary({
    required String departmentId,
  });

  Future<Either<Failure, DashboardKpiDetailEntity>> getKpiDetail({
    required String departmentId,
    required DashboardKpiKind kind,
  });
}
