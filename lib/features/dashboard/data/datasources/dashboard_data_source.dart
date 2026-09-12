import '../../domain/entities/dashboard_department_entity.dart';
import '../../domain/entities/dashboard_kpi_detail_entity.dart';
import '../../domain/entities/dashboard_kpi_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

/// No real backend exists for this screen yet, so unlike every other
/// feature's data source, this one returns domain entities directly instead
/// of `data/models` with a `fromJson` — there's no JSON shape to parse yet,
/// and guessing one now would just have to be redone once a real endpoint
/// exists. Add a `data/models` layer at that point, mirroring
/// `BagDataSource`'s own shape.
abstract class DashboardDataSource {
  Future<List<DashboardDepartmentEntity>> getDepartments();

  Future<DashboardSummaryEntity> getSummary({required String departmentId});

  /// Drill-down table behind whichever KPI card was tapped.
  Future<DashboardKpiDetailEntity> getKpiDetail({
    required String departmentId,
    required DashboardKpiKind kind,
  });
}
