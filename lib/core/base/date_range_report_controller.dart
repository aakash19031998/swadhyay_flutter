import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_strings.dart';
import '../widgets/app_snackbar.dart';

/// Template-method base for every "From/To date range + Show" report screen
/// (Artist Production Report, QC Checker Report). Subclasses implement
/// [fetchReport]; this base owns the date fields, validation, and
/// loading/error/hasSearched state so it isn't re-implemented per screen.
/// Doesn't reload on every keystroke, but loads once automatically for
/// today's date (via [onInit]) so the screen isn't empty on first open.
abstract class DateRangeReportController extends GetxController {
  final Rx<DateTime> fromDate = DateTime.now().obs;

  /// Nulled out whenever [fromDate] changes (see [pickFromDate]) so the
  /// user always has to explicitly re-confirm a To date instead of
  /// silently keeping one that may now sit before the new From date.
  final Rx<DateTime?> toDate = Rx<DateTime?>(DateTime.now());

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

    await fetchReport(fromDate.value, to);

    isLoading.value = false;
  }

  /// Subclasses call their own use case here with the validated [from]/[to]
  /// range, folding the result into their own observables (or
  /// [errorMessage] on failure).
  Future<void> fetchReport(DateTime from, DateTime to);
}
