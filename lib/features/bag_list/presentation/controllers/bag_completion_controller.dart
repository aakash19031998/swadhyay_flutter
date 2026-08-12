import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/entities/comp_pred_entity.dart';
import '../../domain/entities/sub_work_type_entity.dart';
import '../../domain/usecases/get_bag_completion_master_usecase.dart';
import '../../domain/usecases/get_sub_work_types_usecase.dart';
import '../../domain/usecases/submit_bag_done_usecase.dart';
import '../../domain/usecases/validate_add_btn_usecase.dart';
import '../widgets/submit_confirmation_dialog.dart';
import 'bag_list_controller.dart';
import 'bag_timer_controller.dart';

class SettingEntry {
  const SettingEntry({this.trnId, this.setId, required this.setting, required this.pieces});

  final String? trnId;
  final int? setId;
  final String setting;
  final int pieces;
}

/// Drives the "Done" completion form opened from both the bag list and the
/// bag detail screen: record which settings/pieces were worked on, then
/// submit to close out the bag. Work Type options, whether the Add Dummy
/// Work Entry section is enabled, and the pending settings table are all
/// bound from `BagDoneDetail`, fetched once on init.
class BagCompletionController extends GetxController {
  BagCompletionController(
    this.bag,
    this._getCurrentEmployee,
    this._getBagCompletionMaster,
    this._getSubWorkTypes,
    this._validateAddBtn,
    this._submitBagDone,
  );

  final BagEntity bag;
  final GetCurrentEmployeeUseCase _getCurrentEmployee;
  final GetBagCompletionMasterUseCase _getBagCompletionMaster;
  final GetSubWorkTypesUseCase _getSubWorkTypes;
  final ValidateAddBtnUseCase _validateAddBtn;
  final SubmitBagDoneUseCase _submitBagDone;

  /// `BagSchr` from `BagDoneDetail` — sent as `schr` when fetching
  /// `SubWorkType` options for whichever Work Type the user selects.
  String _bagSchr = '';

  /// `BagPcs`/`BagDia` from `BagDoneDetail` — sent as `emrPcs`/`emrStone`
  /// when validating an "ADD" tap via `DummyAddBtnValidation`.
  num _bagPcs = 0;
  int _bagDia = 0;

  /// `SubWorkType`'s full option list (label + `WorkId`) for whichever Work
  /// Type is currently selected — [workOptions] is just the label
  /// projection of this the Work dropdown displays; the `WorkId` behind
  /// the selected label is looked up from here when validating an "ADD".
  List<SubWorkTypeEntity> _subWorkTypes = [];

  /// `AddDummyWork` from `BagDoneDetail` — gates the whole Add Dummy Work
  /// Entry section (Work Type/Work/Piece controls) on/off.
  final RxBool addDummyWork = false.obs;

  /// `WorkType` from `BagDoneDetail`, displayed via `MstProWrkSubCtg`. Left
  /// empty (and never loaded) when `addDummyWork` is false.
  final RxList<String> workTypeOptions = <String>[].obs;

  /// `SubWorkType`'s `Work` options for whichever Work Type is currently
  /// selected — refetched every time [onWorkTypeChanged] fires.
  final RxList<String> workOptions = <String>[].obs;

  final Rxn<String> workType = Rxn<String>();
  final Rxn<String> work = Rxn<String>();
  final RxString piece = ''.obs;

  /// Owns the Piece/Stone field's actual on-screen text. [AppTextField]
  /// without an explicit `controller` manages its text entirely inside
  /// Flutter's own `TextFormField` state — resetting [piece] alone (the
  /// value used for `canAdd`/`inputQty`) never touched what was visibly on
  /// screen, so a successful add cleared the model but left the old digits
  /// showing. Cleared alongside [piece] wherever the form resets.
  final TextEditingController pieceController = TextEditingController();

  final RxList<SettingEntry> recordedSettings = <SettingEntry>[].obs;

  /// `CompPred` from `BagDoneDetail` — drives the "Completed Work" table.
  final RxList<CompPredEntity> completedWork = <CompPredEntity>[].obs;

  /// True while the `BagDoneDetail` fetch is in flight — drives [AppLoader]
  /// on the Done screen until every field above is actually set.
  final RxBool isLoading = true.obs;

  bool get canAdd =>
      addDummyWork.value &&
      workType.value != null &&
      work.value != null &&
      (int.tryParse(piece.value.trim()) ?? 0) > 0;

  @override
  void onInit() {
    super.onInit();
    _loadMaster();
  }

  Future<void> _loadMaster() async {
    isLoading.value = true;
    try {
      final String? empCode = (await _getCurrentEmployee())?.empCode;
      final result = await _getBagCompletionMaster(trnId: bag.id, empCd: empCode ?? '');

      result.fold(
        (failure) => AppSnackbar.show(
          title: AppStrings.alertWarning,
          message: failure.message,
          isSuccess: false,
        ),
        (master) {
          _bagSchr = master.bagSchr;
          _bagPcs = master.bagPcs;
          _bagDia = master.bagDia;
          addDummyWork.value = master.addDummyWork;
          workTypeOptions.value = master.addDummyWork ? master.workType : <String>[];
          recordedSettings.value = [
            for (final pred in master.pndPred)
              SettingEntry(trnId: pred.trnId, setId: pred.setId, setting: pred.pred, pieces: pred.pcs),
          ];
          completedWork.value = master.compPred;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches `SubWorkType`'s options for [value] to populate the Work
  /// dropdown — the previous selection/options are cleared first since
  /// they belong to whichever Work Type was selected before.
  void onWorkTypeChanged(String? value) {
    workType.value = value;
    work.value = null;
    workOptions.clear();

    if (value != null) _loadSubWorkTypes(value);
  }

  Future<void> _loadSubWorkTypes(String workTypeValue) async {
    final String? empCode = (await _getCurrentEmployee())?.empCode;
    final result = await _getSubWorkTypes(schr: _bagSchr, workType: workTypeValue, empCd: empCode ?? '');

    result.fold(
      (failure) => AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: failure.message,
        isSuccess: false,
      ),
      (options) {
        _subWorkTypes = options;
        workOptions.value = [for (final option in options) option.work];
      },
    );
  }

  void onWorkChanged(String? value) => work.value = value;

  void onPieceChanged(String value) => piece.value = value;

  /// Validates the current Work/Piece selection via `DummyAddBtnValidation`
  /// before adding it to the Pending Work table — a `false` status is a
  /// normal rejection (e.g. "Please Enter Proper Input Qty."), surfaced via
  /// the same failure snackbar as everywhere else, and the row is not
  /// added.
  Future<void> addEntry() async {
    if (!canAdd) return;

    final String selectedWork = work.value!;
    final int addedPieces = int.parse(piece.value.trim());
    int selectedWorkId = 0;
    for (final option in _subWorkTypes) {
      if (option.work == selectedWork) {
        selectedWorkId = option.workId;
        break;
      }
    }

    final String? empCode = (await _getCurrentEmployee())?.empCode;
    final result = await _validateAddBtn(
      empCd: empCode ?? '',
      setId: selectedWorkId,
      inputQty: addedPieces,
      emrPcs: _bagPcs.round(),
      emrStone: _bagDia,
    );

    result.fold(
      (failure) => AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: failure.message,
        isSuccess: false,
      ),
      (validation) {
        if (!validation.success) {
          AppSnackbar.show(
            title: AppStrings.alertWarning,
            message: validation.message,
            isSuccess: false,
          );
          return;
        }

        // Same Set ID recorded again overrides that row's setting/pieces
        // with the new selection entirely, rather than incrementing —
        // e.g. an existing "Brc Chillai" / 1 row for Set ID 4124 becomes
        // "Chillai" / 2 if Set ID 4124 is added again with those values.
        // Only a Set ID not yet recorded gets a new row.
        final int existingIndex = recordedSettings.indexWhere((entry) => entry.setId == selectedWorkId);
        if (existingIndex == -1) {
          recordedSettings.add(
            SettingEntry(trnId: bag.id, setId: selectedWorkId, setting: selectedWork, pieces: addedPieces),
          );
        } else {
          final SettingEntry existing = recordedSettings[existingIndex];
          recordedSettings[existingIndex] = SettingEntry(
            trnId: existing.trnId,
            setId: selectedWorkId,
            setting: selectedWork,
            pieces: addedPieces,
          );
        }

        // Clears the whole form — Work Type included — back to its
        // pre-selection state, ready for the next entry.
        workType.value = null;
        work.value = null;
        piece.value = '';
        pieceController.clear();
        workOptions.clear();
      },
    );
  }

  void removeEntry(int index) => recordedSettings.removeAt(index);

  Future<void> submit() async {
    if (recordedSettings.isEmpty) {
      AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: AppStrings.addSettingBeforeSubmit,
        isSuccess: false,
      );
      return;
    }

    final bool confirmed = await SubmitConfirmationDialog.show();
    if (!confirmed) return;

    final String proId = recordedSettings.map((entry) => '${entry.setId}~${entry.pieces}').join(',');
    final String? empCode = (await _getCurrentEmployee())?.empCode;
    final result = await _submitBagDone(trnId: bag.id, proId: proId, empCd: empCode ?? '');

    result.fold(
      (failure) => AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: failure.message,
        isSuccess: false,
      ),
      (response) {
        if (!response.success) {
          // Stays on this screen — a `false` status is a rejection (e.g.
          // an invalid proId), not something a retry-elsewhere fixes.
          AppSnackbar.show(
            title: AppStrings.alertWarning,
            message: response.message,
            isSuccess: false,
          );
          return;
        }

        AppSnackbar.show(
          title: AppStrings.success,
          message: response.message,
          isSuccess: true,
        );

        // Only now — once the work entry is actually submitted, not merely
        // on navigating to this screen — does the bag's Done button on the
        // Bag List/Bag Detail screens flip to "Completed".
        BagTimerController.of(bag).done();

        // Back to the Bag List screen either way — whether Done was opened
        // directly from Bag List or via Bag Detail, this always lands on
        // Bag List (removing Bag Detail from the stack too, in the latter
        // case), refreshed.
        Get.until((route) => route.settings.name == AppRoutes.bagList);
        if (Get.isRegistered<BagListController>()) {
          Get.find<BagListController>().refreshData();
        }
      },
    );
  }

  void cancel() => Get.back();

  @override
  void onClose() {
    pieceController.dispose();
    super.onClose();
  }
}
