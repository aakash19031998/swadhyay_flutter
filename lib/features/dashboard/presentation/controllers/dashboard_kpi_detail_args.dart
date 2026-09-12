import '../../domain/entities/dashboard_kpi_entity.dart';

/// [Get.toNamed] arguments for the generic KPI drill-down screen — one
/// screen shape (search + table) reused by all four Dashboard KPI cards,
/// [kind] says which one so the controller can fetch the right table.
class DashboardKpiDetailArgs {
  const DashboardKpiDetailArgs({
    required this.departmentId,
    required this.kind,
  });

  final String departmentId;
  final DashboardKpiKind kind;
}
