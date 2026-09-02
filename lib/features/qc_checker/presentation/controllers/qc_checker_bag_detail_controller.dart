import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_repair_checklist_item_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_repair_qty_entity.dart';
import '../../../qc_pending_dashboard/domain/usecases/get_qc_repair_checklist_usecase.dart';
import '../../../qc_pending_dashboard/domain/usecases/submit_qc_action_usecase.dart';

/// Drives the new "Bag Info / Repair Details" screen — opened from a
/// [QcCheckerBagGrid] card's OK or Repair tap (both open this same screen;
/// it already offers both actions directly). Same checklist-fetch/submit
/// logic as `QcBagListController._openAction`/`_submitAction`, reused via
/// the same use cases rather than duplicated, just moved to its own screen
/// instead of a dialog opened from a card tap.
class QcCheckerBagDetailController extends GetxController {
  QcCheckerBagDetailController(
    this._getRepairChecklistUseCase,
    this._submitQcActionUseCase,
    this._getCurrentEmployeeUseCase,
    LocalStorageService localStorageService, {
    required this.bag,
  }) : _diaQcChecker = localStorageService.selectedDiaQcChecker;

  final GetQcRepairChecklistUseCase _getRepairChecklistUseCase;
  final SubmitQcActionUseCase _submitQcActionUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final QcAssignedBagEntity bag;

  /// The Diamond QC Checker centrally selected on the QC Checker screen
  /// (same [LocalStorageService] bridge `QcBagListController` reads for
  /// `QcActionDialog`) — read once, since it does not change while this
  /// screen is open.
  final Map<String, dynamic>? _diaQcChecker;

  String? get checkerName => _diaQcChecker == null
      ? null
      : '${_diaQcChecker['qcName']} (${_diaQcChecker['qcCode']})';

  final RxList<QcRepairChecklistItemEntity> repairChecklist =
      <QcRepairChecklistItemEntity>[].obs;
  final RxBool isLoadingChecklist = false.obs;
  final RxBool isSubmittingOk = false.obs;
  final RxBool isSubmittingRepair = false.obs;

  String? _userEmpCd;

  @override
  void onInit() {
    super.onInit();
    _loadRepairChecklist();
  }

  /// `QCRepairList` — `empCd` here is the bag's own `ArtistCd` (see
  /// `QcAssignedBagEntity.artistCd`, bound from `QCPendingBagSingle`), not
  /// the logged-in checker's code (that's [_userEmpCd], used only for
  /// `BagFinalReceive`'s `userEmpCd` on submit).
  Future<void> _loadRepairChecklist() async {
    isLoadingChecklist.value = true;
    final result = await _getRepairChecklistUseCase(
      schr: bag.process,
      empCd: bag.artistCd ?? '',
    );
    result.fold(
      AppSnackbar.showFailure,
      (data) => repairChecklist.assignAll(data),
    );
    isLoadingChecklist.value = false;
  }

  /// "OK (Pass QC)" — same `BagFinalReceive` call as the dashboard's OK
  /// action, always with an empty repair list.
  Future<void> onOk() async {
    isSubmittingOk.value = true;
    await _submit(action: 'O', repairList: const []);
    isSubmittingOk.value = false;
  }

  /// "Submit Repair Details" — same `BagFinalReceive` call as the
  /// dashboard's Repair action, with whichever checklist rows the caller
  /// (the Repair Details panel) gave a quantity greater than zero.
  Future<void> onSubmitRepair(List<QcRepairQtyEntity> repairList) async {
    isSubmittingRepair.value = true;
    await _submit(action: 'R', repairList: repairList);
    isSubmittingRepair.value = false;
  }

  Future<void> _submit({
    required String action,
    required List<QcRepairQtyEntity> repairList,
  }) async {
    _userEmpCd ??= (await _getCurrentEmployeeUseCase())?.empCode;

    final result = await _submitQcActionUseCase(
      action: action,
      trnId: '${bag.trnId}',
      bagNo: bag.bagNo,
      // The bag's own emp code (`ArtistCd`), same as `QcBagListController.
      // _submitAction`'s `empCd: empCode` — [_userEmpCd] is only the
      // logged-in checker, used for `userEmpCd` below.
      empCd: bag.artistCd ?? '',
      userEmpCd: _userEmpCd ?? '',
      process: bag.process,
      diaQcCd: _diaQcChecker?['qcCode'] as String? ?? '0',
      repairList: repairList,
    );

    result.fold(
      AppSnackbar.showFailure,
      (data) {
        // `Get.back()` must run *before* the snackbar — same ordering note
        // as `QcBagListController._submitAction`: it's a "smart back" that
        // dismisses whatever's topmost (Snackbar, then Dialog, then Route),
        // so showing the snackbar first would make it close that instead of
        // this screen. Returns `true` so `QcCheckerController.openBagDetail`
        // knows to clear its search bar/results once back on that screen.
        if (data.success) Get.back(result: true);
        AppSnackbar.show(
          title: AppStrings.alertWarning,
          message: data.message,
          isSuccess: data.success,
        );
      },
    );
  }
}
