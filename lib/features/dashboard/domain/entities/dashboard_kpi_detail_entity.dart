import 'package:equatable/equatable.dart';

import 'dashboard_kpi_entity.dart';

/// Friendly title for the drill-down screen opened by tapping a KPI card —
/// kept next to [DashboardKpiKind] itself since it's the same "which KPI is
/// this" concept, just Title Case instead of the card's own uppercase
/// label.
extension DashboardKpiKindTitle on DashboardKpiKind {
  String get detailTitle => switch (this) {
    DashboardKpiKind.firstReceive => 'First Receive',
    DashboardKpiKind.qcPending => 'QC Pending',
    DashboardKpiKind.articleCount => 'Article Count',
    DashboardKpiKind.empCount => 'Employee Count',
  };
}

class DashboardKpiDetailColumn extends Equatable {
  const DashboardKpiDetailColumn({required this.label, this.flex = 1});

  final String label;
  final int flex;

  @override
  List<Object?> get props => [label, flex];
}

/// The drill-down table behind a Dashboard KPI card — one [FlexTable] shell
/// (same as Bag Detail's Diamond Details/Bag RM Summary and Design
/// Master's own tables) reused for all four KPIs, since only the columns
/// and row data differ between them.
class DashboardKpiDetailEntity extends Equatable {
  const DashboardKpiDetailEntity({required this.columns, required this.rows});

  final List<DashboardKpiDetailColumn> columns;
  final List<List<String>> rows;

  @override
  List<Object?> get props => [columns, rows];
}
