import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/artist_production_entity.dart';
import '../../domain/usecases/get_artist_production_usecase.dart';

/// Per-work-type totals derived from [ArtistProductionController.items] —
/// the second ("no prediction") table on the report is this summary, not a
/// separate fetch.
class WorkTypeSummary {
  const WorkTypeSummary({required this.workType, required this.actualQty, required this.totalPoints});

  final String workType;
  final int actualQty;
  final double totalPoints;
}

/// Drives the Artist Production Report screen: a From/To date range and a
/// "Show" action to re-run it — unlike the other list reports in the app,
/// this one doesn't reload on every keystroke, but it does load once
/// automatically for today's date so the screen isn't empty on first open.
class ArtistProductionController extends GetxController {
  ArtistProductionController(this._getArtistProductionUseCase);

  final GetArtistProductionUseCase _getArtistProductionUseCase;

  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  final RxList<ArtistProductionEntity> items = <ArtistProductionEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    show();
  }

  List<WorkTypeSummary> get summary {
    final Map<String, WorkTypeSummary> grouped = {};
    for (final entry in items) {
      final WorkTypeSummary? existing = grouped[entry.workType];
      grouped[entry.workType] = WorkTypeSummary(
        workType: entry.workType,
        actualQty: (existing?.actualQty ?? 0) + entry.actualQty,
        totalPoints: (existing?.totalPoints ?? 0) + entry.totalPoints,
      );
    }
    return grouped.values.toList();
  }

  Future<void> pickFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) fromDate.value = picked;
  }

  Future<void> pickToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) toDate.value = picked;
  }

  Future<void> show() async {
    if (fromDate.value.isAfter(toDate.value)) {
      Get.snackbar(AppStrings.somethingWentWrong, AppStrings.invalidDateRange);
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    hasSearched.value = true;

    final result = await _getArtistProductionUseCase(fromDate: fromDate.value, toDate: toDate.value);
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => items.assignAll(data),
    );

    isLoading.value = false;
  }
}
