import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../bag_list/domain/usecases/get_bag_media_usecase.dart';
import '../../../bag_list/presentation/controllers/bag_media_viewer_args.dart';
import '../../domain/entities/qc_assigned_bag_entity.dart';
import '../../domain/entities/qc_repair_qty_entity.dart';
import '../../domain/usecases/get_qc_assigned_bags_usecase.dart';
import '../../domain/usecases/get_qc_repair_checklist_usecase.dart';
import '../../domain/usecases/submit_qc_action_usecase.dart';
import '../widgets/qc_action_dialog.dart';

/// Drives the "QC Bag List" screen opened from one employee's [QcCheckCard]
/// — the bags currently in that employee's QC queue. Same "load once,
/// filter locally" search shape as `BagListController`/`QcPendingDashboardController`.
class QcBagListController extends ListStateController<QcAssignedBagEntity> {
  QcBagListController(
    this._getQcAssignedBagsUseCase,
    this._getQcRepairChecklistUseCase,
    this._getBagMediaUseCase,
    this._submitQcActionUseCase,
    this._getCurrentEmployeeUseCase,
    this._localStorageService, {
    required this.empCode,
    required this.empName,
    required this.totalBags,
    required this.totalPieces,
    this.imageUrl,
  });

  final GetQcAssignedBagsUseCase _getQcAssignedBagsUseCase;
  final GetQcRepairChecklistUseCase _getQcRepairChecklistUseCase;
  final GetBagMediaUseCase _getBagMediaUseCase;
  final SubmitQcActionUseCase _submitQcActionUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final LocalStorageService _localStorageService;
  final String empCode;
  final String empName;
  final int totalBags;
  final int totalPieces;
  final String? imageUrl;

  /// Backs the search field so a scanned barcode/QR value can be shown in
  /// the field itself (not just applied as a silent filter) — same as
  /// Bag List's own search field.
  final TextEditingController searchController = TextEditingController();

  List<QcAssignedBagEntity> _allBags = const [];

  /// The logged-in app user's own emp code — `BagFinalReceive`'s
  /// `userEmpCd`, distinct from [empCode] (the bag holder being QC'd).
  /// Loaded once, on first submit, same caching shape as
  /// `QcPendingDashboardController`'s own `_empCd`.
  String? _userEmpCd;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<QcAssignedBagEntity> _filter(String value) {
    final String needle = value.trim().toLowerCase();
    if (needle.isEmpty) return _allBags;
    return _allBags
        .where(
          (bag) =>
              bag.bagNo.toLowerCase().contains(needle) ||
              bag.orderNo.toLowerCase().contains(needle) ||
              bag.style.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  @override
  void onQueryChanged(String value) {
    query.value = value;
    items.assignAll(_filter(value));
  }

  void onScanned(String value) {
    searchController.text = value;
    onQueryChanged(value);
  }

  List<String> suggestionsFor(String text) {
    final String needle = text.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    final List<String> matches = [];
    for (final bag in _allBags) {
      if (bag.bagNo.toLowerCase().contains(needle) && !matches.contains(bag.bagNo)) {
        matches.add(bag.bagNo);
      }
      if (bag.orderNo.toLowerCase().contains(needle) && !matches.contains(bag.orderNo)) {
        matches.add(bag.orderNo);
      }
    }
    return matches.take(8).toList(growable: false);
  }

  @override
  Future<Either<Failure, List<QcAssignedBagEntity>>> fetch(String searchQuery) async {
    final result = await _getQcAssignedBagsUseCase(empCode: empCode);
    return result.fold(
      (failure) => Left(failure),
      (list) {
        _allBags = list;
        return Right(_filter(query.value));
      },
    );
  }

  /// Fetches this bag's image/video gallery from `ImageAndVideoUrls` (using
  /// the bag's own `style` as `styleCd`, and this screen's already-selected
  /// employee as `empCd`) and opens the shared media viewer — same screen
  /// Bag List/Design Master also open. A fresh network call per tap, so a
  /// blocking loader covers the wait.
  Future<void> openBagMedia(QcAssignedBagEntity bag) async {
    AppDialog.loading();
    final result = await _getBagMediaUseCase(empCd: empCode, styleCd: bag.style);
    AppDialog.dismiss();

    result.fold(
      (failure) => AppSnackbar.show(title: AppStrings.alertWarning, message: failure.message, isSuccess: false),
      (media) {
        if (media.isEmpty) {
          AppSnackbar.show(title: AppStrings.alertWarning, message: AppStrings.noMediaFound, isSuccess: false);
          return;
        }
        Get.toNamed(AppRoutes.bagMediaViewer, arguments: BagMediaViewerArgs(media: media));
      },
    );
  }

  void onBagOk(QcAssignedBagEntity bag) => _openAction(QcActionMode.ok, bag);

  void onBagRepair(QcAssignedBagEntity bag) => _openAction(QcActionMode.repair, bag);

  /// Fetches `QCRepairList` fresh for this specific bag's `Process` (`schr`)
  /// and the selected employee (`empCd`) — the repair checklist depends on
  /// the process code, so it can't be preloaded once for the whole screen
  /// the way the old mock list was. The Diamond QC Checker, by contrast, is
  /// picked once centrally on the QC Checking screen and read back here
  /// from local storage — see `QcPendingDashboardController.selectDiaQcChecker`.
  Future<void> _openAction(QcActionMode mode, QcAssignedBagEntity bag) async {
    AppDialog.loading();
    final result = await _getQcRepairChecklistUseCase(schr: bag.process, empCd: empCode);
    AppDialog.dismiss();

    final Map<String, dynamic>? selectedChecker = _localStorageService.selectedDiaQcChecker;
    final String? diaQcCode = selectedChecker?['qcCode'] as String?;
    final String? diaQcCheckerName =
        selectedChecker == null ? null : '${selectedChecker['qcName']} (${selectedChecker['qcCode']})';

    result.fold(
      (failure) => AppSnackbar.show(title: AppStrings.alertWarning, message: failure.message, isSuccess: false),
      (checklist) => QcActionDialog.show(
        mode: mode,
        bagNo: bag.bagNo,
        styleNo: bag.style,
        pieces: bag.pieces,
        checklist: checklist,
        diaQcCheckerName: diaQcCheckerName,
        onSubmit: (repairList) => _submitAction(mode, bag, diaQcCode, repairList),
      ),
    );
  }

  /// Submits `BagFinalReceive` — `diaQcCd` is the centrally-selected
  /// Diamond QC Checker's code, or `"0"` when none is selected, the same
  /// for both OK and Repair. OK always sends an empty `repairList` (its
  /// quantities stay locked at 0); Repair sends only the items the user
  /// actually specified a quantity for. `status: true` and `false` are
  /// both normal outcomes here, not failures — either way `message` is
  /// shown on the snackbar; only an actual network/server error takes the
  /// [Failure] path instead. On a successful submit, the dialog closes and
  /// the bag list refreshes so the now-finalized bag drops off it.
  Future<void> _submitAction(
    QcActionMode mode,
    QcAssignedBagEntity bag,
    String? diaQcCode,
    List<QcRepairQtyEntity> repairList,
  ) async {
    final bool isOk = mode == QcActionMode.ok;
    _userEmpCd ??= (await _getCurrentEmployeeUseCase())?.empCode;

    // No `AppDialog.loading()` overlay here — `QcActionDialog` shows its
    // own inline Submit-button spinner instead (see `_submitting` there).
    final result = await _submitQcActionUseCase(
      action: isOk ? 'O' : 'R',
      trnId: '${bag.trnId}',
      bagNo: bag.bagNo,
      empCd: empCode,
      userEmpCd: _userEmpCd ?? '',
      process: bag.process,
      diaQcCd: diaQcCode ?? '0',
      repairList: isOk ? const [] : repairList,
    );

    result.fold(
      (failure) => AppSnackbar.show(title: AppStrings.alertWarning, message: failure.message, isSuccess: false),
      (data) {
        // `Get.back()` must run *before* the snackbar: `Get.back()` is a
        // "smart back" that dismisses whatever's topmost in a fixed
        // priority — Snackbar, then Dialog, then Route. Showing the
        // snackbar first left one already open, so `Get.back()` closed
        // *that* instead of this dialog, which then just sat there fully
        // intact — confirmed live: `isSnackbarOpen` was `true` right
        // before the call, and the dialog was still mounted right after.
        if (data.success) {
          Get.back<void>();
          refreshData();
        }
        AppSnackbar.show(title: AppStrings.alertWarning, message: data.message, isSuccess: data.success);
      },
    );
  }
}
