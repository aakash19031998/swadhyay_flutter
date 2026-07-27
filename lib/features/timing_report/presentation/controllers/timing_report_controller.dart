import 'package:get/get.dart';

import '../../domain/entities/timing_report_entity.dart';
import '../../domain/usecases/get_timing_report_usecase.dart';

/// Drives the Timing Report bar chart: loads the selected calendar month
/// (defaulting to the current month, switchable via a dropdown covering the
/// past 12 months) — no search, no manual trigger, every day in the month
/// is always shown. The number of bars is always exactly [daysInMonth],
/// computed from the real calendar rather than hardcoded, so it's correct
/// whichever month is loaded (28 for Feb, 30 or 31 elsewhere).
class TimingReportController extends GetxController {
  TimingReportController(this._getTimingReportUseCase);

  final GetTimingReportUseCase _getTimingReportUseCase;

  final DateTime _now = DateTime.now();

  final RxList<TimingReportEntity> entries = <TimingReportEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  /// The currently selected month (day/time components always zeroed — only
  /// year/month are meaningful). Defaults to the current month.
  late final Rx<DateTime> selectedMonth = DateTime(_now.year, _now.month).obs;

  /// The past 12 months (this one included), most recent first — the
  /// dropdown's selectable range.
  List<DateTime> get pastYearMonths => List.generate(12, (i) => DateTime(_now.year, _now.month - i));

  int get year => selectedMonth.value.year;

  int get month => selectedMonth.value.month;

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  // Till-date totals shown in the pie chart — plain sums over the currently
  // loaded [entries], not a separate fetch.
  int get totalUsedMinutes => entries.fold<int>(0, (sum, e) => sum + e.usedMinutes);

  int get totalUnusedMinutes => entries.fold<int>(0, (sum, e) => sum + e.unusedMinutes);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void onMonthChanged(DateTime? value) {
    if (value == null || value == selectedMonth.value) return;
    selectedMonth.value = value;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getTimingReportUseCase(year: year, month: month);
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => entries.assignAll(data),
    );

    isLoading.value = false;
  }
}
