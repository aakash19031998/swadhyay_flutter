import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../bag_list/domain/usecases/get_bag_media_usecase.dart';
import '../../../bag_list/presentation/controllers/bag_media_viewer_args.dart';
import '../../../qc_pending_dashboard/domain/entities/department_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/dia_qc_checker_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../../domain/usecases/get_qc_checker_departments_usecase.dart';
import '../../domain/usecases/search_qc_checker_bag_usecase.dart';

/// Drives the new, simplified "QC Checker" first screen: department
/// sidebar + Diamond QC Checker filter + bag search/scan, then a bag list
/// (same grid design as the QC Pending Dashboard's own `QcBagListView`) —
/// deliberately without the QC Pending Dashboard's emp grid (see
/// `QcPendingDashboardController` for that full feature set, which this
/// screen does not reuse). Tapping OK or Repair on a bag card opens the
/// Bag Info/Repair Details screen (`QcCheckerBagDetailController`) instead
/// of anything happening inline here.
class QcCheckerController extends GetxController {
  QcCheckerController(
    this._getDepartmentsUseCase,
    this._searchBagUseCase,
    this._getBagMediaUseCase,
    this._getCurrentEmployeeUseCase,
    this._localStorageService,
  );

  final GetQcCheckerDepartmentsUseCase _getDepartmentsUseCase;
  final SearchQcCheckerBagUseCase _searchBagUseCase;
  final GetBagMediaUseCase _getBagMediaUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final LocalStorageService _localStorageService;

  String? _empCd;

  /// Backs the search field so a scanned bag no. can be shown in the field
  /// itself, same as `QcBagListController.onScanned`.
  final TextEditingController searchController = TextEditingController();

  final RxList<DepartmentEntity> departments = <DepartmentEntity>[].obs;
  final Rxn<DepartmentEntity> selectedDepartment = Rxn<DepartmentEntity>();
  final RxBool isLoadingDepartments = true.obs;

  /// The "Diamond QC Checker" dropdown's option list — from
  /// `QCDepartmentN`'s `DiaQcList`, fetched together with [departments] in
  /// [_loadDepartments].
  final RxList<DiaQcCheckerEntity> diaQcCheckers = <DiaQcCheckerEntity>[].obs;

  /// Persisted via the same [LocalStorageService] key the QC Pending
  /// Dashboard uses, so a pick here carries over to
  /// `QcCheckerBagDetailController`'s "Checker" field on the next screen.
  final Rxn<DiaQcCheckerEntity> selectedDiaQcChecker =
      Rxn<DiaQcCheckerEntity>();

  /// The bag no. currently searched/scanned — `null` until the user has
  /// typed or scanned something.
  final RxnString searchedBagNo = RxnString();

  /// The bag list shown below the search bar once something's been typed/
  /// scanned — from `QCPendingBagSingle` (see [_searchBagUseCase]), keyed by
  /// the scanned/typed barcode rather than by employee.
  final RxList<QcAssignedBagEntity> bagResults = <QcAssignedBagEntity>[].obs;

  /// `true` while `QCPendingBagSingle` is in flight — gates the loader
  /// shown in place of the bag grid/empty state until results arrive.
  final RxBool isLoadingBagResults = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDepartments();
  }

  @override
  void onClose() {
    searchController.dispose();
    _localStorageService.clearSelectedDiaQcChecker();
    super.onClose();
  }

  Future<void> _loadDepartments() async {
    isLoadingDepartments.value = true;
    _empCd ??= (await _getCurrentEmployeeUseCase())?.empCode;
    final result = await _getDepartmentsUseCase(empCd: _empCd ?? '');
    result.fold(
      AppSnackbar.showFailure,
      (data) {
        departments.assignAll(data.departments);
        diaQcCheckers.assignAll(data.diaQcCheckers);
      },
    );
    isLoadingDepartments.value = false;
  }

  void selectDepartment(DepartmentEntity department) {
    if (selectedDepartment.value?.id == department.id) return;
    selectedDepartment.value = department;
  }

  void selectDiaQcChecker(DiaQcCheckerEntity value) {
    selectedDiaQcChecker.value = value;
    _localStorageService.saveSelectedDiaQcChecker({
      'qcCode': value.qcCode,
      'qcName': value.qcName,
    });
  }

  /// Typing alone no longer loads the list — only clears it once the field
  /// is emptied. Loading now waits for an explicit tap on the "Show"
  /// button (see [showBagResults]), so a half-typed bag no. doesn't flash
  /// results while the user is still typing.
  void onBagFieldChanged(String value) {
    if (value.trim().isEmpty) {
      searchedBagNo.value = null;
      bagResults.clear();
    }
  }

  /// "Show" button beside the search field — loads the list for whatever
  /// bag no. is currently typed.
  void showBagResults() => _loadBagResults(searchController.text);

  /// Scanning loads the list immediately, unlike typing — there's no
  /// separate "Show" tap to wait for once a barcode's already been read.
  void onScanned(String value) {
    searchController.text = value;
    _loadBagResults(value);
  }

  Future<void> _loadBagResults(String value) async {
    final String trimmed = value.trim();
    searchedBagNo.value = trimmed.isEmpty ? null : trimmed;

    if (trimmed.isEmpty) {
      bagResults.clear();
      return;
    }

    isLoadingBagResults.value = true;
    final result = await _searchBagUseCase(bagBarcode: trimmed);
    result.fold((failure) {
      bagResults.clear();
      AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: failure.message,
        isSuccess: false,
      );
    }, (data) => bagResults.assignAll(data));
    isLoadingBagResults.value = false;
  }

  /// Opens the Bag Info/Repair Details screen for the tapped card — both
  /// OK and Repair land here, since that screen already offers both
  /// actions directly (see `QcCheckerBagGrid`). On a successful OK/Submit
  /// Repair there (`QcCheckerBagDetailController._submit` pops with
  /// `result: true`), the search bar and results here are cleared so the
  /// checker starts fresh for the next bag.
  Future<void> openBagDetail(QcAssignedBagEntity bag) async {
    // Untyped, then checked with `is` — same as `_ScanButton._openScanner`'s
    // own `Get.toNamed` call. `Get.toNamed<bool>(...)` throws ("type
    // 'GetPageRoute<dynamic>' is not a subtype of type 'Route<bool?>?' in
    // type cast") because this app's route table always produces an
    // untyped `GetPageRoute<dynamic>`, which a typed `toNamed` can't cast.
    final dynamic result = await Get.toNamed(
      AppRoutes.qcCheckerBagDetail,
      arguments: bag,
    );
    final bool success = result is bool && result;
    if (success) {
      searchController.clear();
      searchedBagNo.value = null;
      bagResults.clear();
    }
  }

  /// Fetches this bag's image/video gallery from `ImageAndVideoUrls` (the
  /// bag's own `style` as `styleCd`, the logged-in app user as `empCd`) and
  /// opens the same shared media viewer the QC Pending Dashboard/Bag List
  /// screens use — see `QcBagListController.openBagMedia`. Triggered by a
  /// tap on the bag card's thumbnail image (see `QcCheckerBagGrid`), not
  /// the whole card, which still opens the Bag Info/Repair Details screen.
  Future<void> openBagMedia(QcAssignedBagEntity bag) async {
    _empCd ??= (await _getCurrentEmployeeUseCase())?.empCode;
    AppDialog.loading();
    final result = await _getBagMediaUseCase(
      empCd: _empCd ?? '',
      styleCd: bag.style,
    );
    AppDialog.dismiss();

    result.fold(
      AppSnackbar.showFailure,
      (media) {
        if (media.isEmpty) {
          AppSnackbar.show(
            title: AppStrings.alertWarning,
            message: AppStrings.noMediaFound,
            isSuccess: false,
          );
          return;
        }
        Get.toNamed(
          AppRoutes.bagMediaViewer,
          arguments: BagMediaViewerArgs(media: media),
        );
      },
    );
  }
}
