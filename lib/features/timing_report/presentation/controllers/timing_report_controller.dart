import 'package:get/get.dart';

import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/timing_report_entity.dart';
import '../../domain/usecases/get_timing_report_usecase.dart';

/// Drives the Timing Report bar chart. `ArtistTimeUtilizationReport` is
/// scoped by employee only (no year/month request params — unlike the old
/// placeholder endpoint this replaced), so the full history is fetched once
/// and the month dropdown (defaulting to the current month, switchable over
/// the past 12 months) filters that same in-memory snapshot instead of
/// re-fetching per month — same "load once, filter locally" shape as Bag
/// List's search. The number of bars shown always matches the selected
/// month's real day count (28/29/30/31); days the API didn't return show as
/// a zero-value bar instead of shrinking the chart.
class TimingReportController extends GetxController {
  TimingReportController(this._getTimingReportUseCase, this._getCurrentEmployeeUseCase);

  final GetTimingReportUseCase _getTimingReportUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;

  final DateTime _now = DateTime.now();

  final RxList<TimingReportEntity> entries = <TimingReportEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  /// Full, unfiltered snapshot from the last successful load — [entries] is
  /// filtered from this by [selectedMonth], purely in-memory.
  List<TimingReportEntity> _allEntries = const [];

  /// The currently selected month (day/time components always zeroed — only
  /// year/month are meaningful). Defaults to the current month.
  late final Rx<DateTime> selectedMonth = DateTime(_now.year, _now.month).obs;

  /// The past 12 months (this one included), most recent first — the
  /// dropdown's selectable range.
  List<DateTime> get pastYearMonths => List.generate(12, (i) => DateTime(_now.year, _now.month - i));

  // Till-date totals shown in the pie chart — plain sums over the currently
  // loaded [entries], not a separate fetch.
  double get totalUsedMinutes => entries.fold<double>(0, (sum, e) => sum + e.usedMinutes);

  double get totalUnusedMinutes => entries.fold<double>(0, (sum, e) => sum + e.unusedMinutes);

  double get totalPunchedMinutes => entries.fold<double>(0, (sum, e) => sum + e.punchedMinutes);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void onMonthChanged(DateTime? value) {
    if (value == null || value == selectedMonth.value) return;
    selectedMonth.value = value;
    _applyMonthFilter();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    // `finally` so isLoading always clears — even on an exception the
    // repository didn't wrap as a Failure (e.g. an unexpected response
    // shape), which previously left the loader stuck on screen forever.
    try {
      final String? empCode = (await _getCurrentEmployeeUseCase())?.empCode;
      final result = await _getTimingReportUseCase(empCd: empCode ?? '');
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (data) {
          _allEntries = data;
          _applyMonthFilter();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Always one entry per calendar day of [selectedMonth] (28 for Feb, 30/31
  /// elsewhere) — real days the API didn't return (nothing punched, or
  /// simply not part of the response) show as a zero-value entry rather
  /// than being skipped, so the chart's day count always matches the actual
  /// month instead of just however many days the API happened to send.
  void _applyMonthFilter() {
    final DateTime month = selectedMonth.value;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final Map<int, TimingReportEntity> byDay = {
      for (final entry in _allEntries)
        if (entry.date.year == month.year && entry.date.month == month.month) entry.date.day: entry,
    };

    entries.assignAll([
      for (int day = 1; day <= daysInMonth; day++)
        byDay[day] ??
            TimingReportEntity(
              date: DateTime(month.year, month.month, day),
              usedMinutes: 0,
              unusedMinutes: 0,
              punchedMinutes: 0,
            ),
    ]);
  }
}
