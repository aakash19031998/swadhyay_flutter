import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/dia_qc_checker_entity.dart';
import '../../domain/entities/qc_check_entity.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_qc_checks_usecase.dart';
import 'qc_bag_list_args.dart';

class QcPendingDashboardController extends ListStateController<QcCheckEntity> {
  QcPendingDashboardController(
    this._getQcChecksUseCase,
    this._getDepartmentsUseCase,
    this._getCurrentEmployeeUseCase,
    this._localStorageService,
  );

  final GetQcChecksUseCase _getQcChecksUseCase;
  final GetDepartmentsUseCase _getDepartmentsUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final LocalStorageService _localStorageService;

  String? _empCd;

  /// Backs the search field so it can be cleared programmatically on a
  /// department switch (see [selectDepartment]).
  final TextEditingController searchController = TextEditingController();

  /// "SELECT DEPARTMENT" sidebar. `null` selection means nothing has been
  /// picked yet — the screen shows a "please select a department" prompt
  /// until one is (see [fetch]), rather than loading anything by default.
  final RxList<DepartmentEntity> departments = <DepartmentEntity>[].obs;
  final Rxn<DepartmentEntity> selectedDepartment = Rxn<DepartmentEntity>();
  final RxBool isLoadingDepartments = true.obs;

  /// `QCDeptList`'s `auto_update` flag ("Y"/"N") — gates whether the 60s
  /// timer below actually refreshes `DeptQCPendingEmpList`.
  bool _autoUpdate = false;

  /// `DeptQCPendingEmpList`'s `DiaQcList` for the currently selected
  /// department — the "Diamond QC Checker" master list shown on this
  /// screen's filter dropdown.
  final RxList<DiaQcCheckerEntity> diaQcCheckers = <DiaQcCheckerEntity>[].obs;

  /// The centrally-selected Diamond QC Checker — applies to every employee/
  /// bag under the current department until changed (see
  /// [selectDiaQcChecker]), and is what the QC OK/Repair popup shows
  /// instead of its own picker. Persisted via [_localStorageService] so
  /// `QcBagListController`/`QcActionDialog` — a separate screen/controller —
  /// can read it without depending on this controller directly.
  final Rxn<DiaQcCheckerEntity> selectedDiaQcChecker = Rxn<DiaQcCheckerEntity>();

  /// Full (unfiltered-by-search) snapshot for the currently selected
  /// department. `query` is applied to this purely in-memory — the same
  /// "load once, filter locally" shape as `BagListController` — so typing
  /// doesn't re-fetch over the network per keystroke, and suggestions can
  /// be drawn from it too.
  List<QcCheckEntity> _allChecks = const [];

  /// Auto-refreshes `DeptQCPendingEmpList` every 60s so the grid stays
  /// current without the user having to pull-to-refresh — but only when
  /// `QCDeptList`'s `auto_update` flag says "Y" (see [_autoUpdate]) and a
  /// department is actually selected (otherwise [fetch] is a no-op anyway).
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadDepartments();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_autoUpdate && selectedDepartment.value != null) refreshData();
    });
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    searchController.dispose();
    // Leaving the QC Checking screen (e.g. back to Home) — the centrally
    // selected Diamond QC Checker shouldn't silently carry over into a
    // future, unrelated QC Checking session.
    _localStorageService.clearSelectedDiaQcChecker();
    super.onClose();
  }

  Future<void> _loadDepartments() async {
    isLoadingDepartments.value = true;
    _empCd ??= (await _getCurrentEmployeeUseCase())?.empCode;
    final result = await _getDepartmentsUseCase(empCd: _empCd ?? '');
    result.fold(
      (failure) => AppSnackbar.show(title: AppStrings.alertWarning, message: failure.message, isSuccess: false),
      (data) {
        departments.assignAll(data.departments);
        _autoUpdate = data.autoUpdate;
      },
    );
    isLoadingDepartments.value = false;
  }

  /// Re-tapping the already-selected department is a no-op — there's no
  /// "All Departments" row to fall back to any more, so toggling back to
  /// `null` would just show the "please select a department" prompt again
  /// for no reason. Also clears any active search on an actual switch,
  /// since a stale filter carried over from the previous department could
  /// otherwise hide everything in the new one.
  void selectDepartment(DepartmentEntity department) {
    if (selectedDepartment.value?.id == department.id) return;
    selectedDepartment.value = department;
    searchController.clear();
    query.value = '';
    // Clears the previous department's cards immediately, not just after
    // the new response arrives — otherwise `ReportListScaffold` only shows
    // its loader when `items` is already empty, so switching from a
    // department that had results would silently keep showing the old
    // ones (no loader) until the new list swapped in.
    items.clear();
    // The Diamond QC Checker selection is scoped to one department — a
    // fresh department means the user must pick again, not silently keep
    // whoever was selected for the previous one.
    diaQcCheckers.clear();
    selectedDiaQcChecker.value = null;
    _localStorageService.clearSelectedDiaQcChecker();
    load();
  }

  /// Sets the centrally-selected Diamond QC Checker for the current
  /// department — persisted so the QC OK/Repair popup (a different
  /// screen/controller) can read it, and stays selected across every
  /// employee/bag until [selectDepartment] clears it or a different option
  /// is picked here.
  void selectDiaQcChecker(DiaQcCheckerEntity value) {
    selectedDiaQcChecker.value = value;
    _localStorageService.saveSelectedDiaQcChecker({'qcCode': value.qcCode, 'qcName': value.qcName});
  }

  List<QcCheckEntity> _filter(String value) {
    final String needle = value.trim().toLowerCase();
    if (needle.isEmpty) return _allChecks;
    return _allChecks.where((c) => c.empCode.toLowerCase().contains(needle)).toList(growable: false);
  }

  /// Re-filters the already-loaded [_allChecks] snapshot in place — no
  /// network call, so there's nothing for a fast search to race against.
  @override
  void onQueryChanged(String value) {
    query.value = value;
    items.assignAll(_filter(value));
  }

  /// Distinct emp codes containing [text], drawn from the full [_allChecks]
  /// snapshot (refreshed on every department switch/refresh) — not
  /// narrowed by whatever's already typed.
  List<String> suggestionsFor(String text) {
    final String needle = text.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    final List<String> matches = [];
    for (final check in _allChecks) {
      if (check.empCode.toLowerCase().contains(needle) && !matches.contains(check.empCode)) {
        matches.add(check.empCode);
      }
    }
    return matches.take(8).toList(growable: false);
  }

  @override
  Future<Either<Failure, List<QcCheckEntity>>> fetch(String searchQuery) async {
    // No "All Departments" option any more — nothing to show (and no
    // reason to call the API) until a department is actually picked.
    final DepartmentEntity? department = selectedDepartment.value;
    if (department == null) {
      _allChecks = const [];
      return const Right([]);
    }

    final result = await _getQcChecksUseCase(deptId: department.id);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        _allChecks = data.checks;
        diaQcCheckers.assignAll(data.diaQcList);
        // Filters by the *current* query.value, not the searchQuery this
        // call started with — see BagListController.fetch for why.
        return Right(_filter(query.value));
      },
    );
  }

  /// Opens the "QC Bag List" screen for this card's employee.
  void viewAssignedBags(QcCheckEntity check) {
    Get.toNamed<void>(
      AppRoutes.qcBagList,
      arguments: QcBagListArgs(
        empCode: check.empCode,
        empName: check.empName,
        totalBags: check.totalBags,
        totalPieces: check.totalPieces,
        imageUrl: check.imageUrl,
      ),
    );
  }
}
