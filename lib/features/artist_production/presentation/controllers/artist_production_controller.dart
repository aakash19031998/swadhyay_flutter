import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/artist_production_entity.dart';
import '../../domain/usecases/get_artist_production_usecase.dart';

/// Drives the Artist Production Report screen: a From/To date range and a
/// "Show" action to re-run it — unlike the other list reports in the app,
/// this one doesn't reload on every keystroke, but it does load once
/// automatically for today's date so the screen isn't empty on first open.
/// `ArtistProductionRpt` returns the till-date KPI totals and both the
/// detail/summary rows in one call, so [show] fans a single response out
/// into all five observables instead of deriving the summary client-side.
class ArtistProductionController extends GetxController {
  ArtistProductionController(this._getArtistProductionUseCase, this._getCurrentEmployeeUseCase);

  final GetArtistProductionUseCase _getArtistProductionUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;

  final Rx<DateTime> fromDate = DateTime.now().obs;

  /// Nulled out whenever [fromDate] changes (see [pickFromDate]) so the
  /// user always has to explicitly re-confirm a To date instead of
  /// silently keeping one that may now sit before the new From date.
  final Rx<DateTime?> toDate = Rx<DateTime?>(DateTime.now());

  final RxList<ArtistProductionDetailEntity> items = <ArtistProductionDetailEntity>[].obs;
  final RxList<ArtistProductionSummaryEntity> summary = <ArtistProductionSummaryEntity>[].obs;

  final RxInt totalPieces = 0.obs;
  final RxInt totalParts = 0.obs;
  final RxDouble totalPointsValue = 0.0.obs;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    show();
  }

  Future<void> pickFromDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    fromDate.value = picked;
    // Force the user to re-confirm a To date on top of the new From date.
    toDate.value = null;
  }

  Future<void> pickToDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? fromDate.value,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) toDate.value = picked;
  }

  Future<void> show() async {
    final DateTime? to = toDate.value;
    if (to == null) {
      AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: AppStrings.toDateRequired,
        isSuccess: false,
      );
      return;
    }
    if (fromDate.value.isAfter(to)) {
      AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: AppStrings.invalidDateRange,
        isSuccess: false,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    hasSearched.value = true;

    final String? empCode = (await _getCurrentEmployeeUseCase())?.empCode;
    final result = await _getArtistProductionUseCase(
      fromDate: fromDate.value,
      toDate: to,
      empCd: empCode ?? '',
    );
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (report) {
        totalPieces.value = report.totalPieces;
        totalParts.value = report.parts;
        totalPointsValue.value = report.points;
        items.assignAll(report.detail);
        summary.assignAll(report.summary);
      },
    );

    isLoading.value = false;
  }
}
