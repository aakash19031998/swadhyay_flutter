import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/dashboard_kpi_detail_entity.dart';
import '../../domain/usecases/get_dashboard_kpi_detail_usecase.dart';
import 'dashboard_kpi_detail_args.dart';

/// Drives the generic KPI drill-down screen opened from any of the
/// Dashboard's four KPI cards, scoped to whichever department was selected
/// there.
class DashboardKpiDetailController extends GetxController {
  DashboardKpiDetailController(this._getKpiDetailUseCase, this.args);

  final GetDashboardKpiDetailUseCase _getKpiDetailUseCase;
  final DashboardKpiDetailArgs args;

  final TextEditingController searchController = TextEditingController();

  final RxList<DashboardKpiDetailColumn> columns =
      <DashboardKpiDetailColumn>[].obs;
  final RxList<List<String>> rows = <List<String>>[].obs;
  final RxBool isLoading = true.obs;

  /// Full (unfiltered) snapshot — the search field filters this purely
  /// in-memory, same "load once, filter locally" shape used elsewhere in
  /// this app (e.g. `BagListController`).
  List<List<String>> _allRows = const [];

  @override
  void onInit() {
    super.onInit();
    _loadDetail();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadDetail() async {
    isLoading.value = true;
    final result = await _getKpiDetailUseCase(
      departmentId: args.departmentId,
      kind: args.kind,
    );
    result.fold(AppSnackbar.showFailure, (data) {
      columns.assignAll(data.columns);
      _allRows = data.rows;
      rows.assignAll(data.rows);
    });
    isLoading.value = false;
  }

  /// A row matches if the query is found in *any* of its cells — this
  /// screen has no single "identifier" column across all four KPIs, so
  /// unlike e.g. `BagListController` (which only searches bag/design
  /// number), searching every cell is the only shape that makes sense
  /// generically.
  void onQueryChanged(String value) {
    final String needle = value.trim().toLowerCase();
    rows.assignAll(
      needle.isEmpty
          ? _allRows
          : _allRows.where(
              (row) => row.any((cell) => cell.toLowerCase().contains(needle)),
            ),
    );
  }
}
