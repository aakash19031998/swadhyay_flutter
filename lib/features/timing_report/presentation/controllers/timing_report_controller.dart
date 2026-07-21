import 'package:get/get.dart';

import '../../domain/entities/timing_report_entity.dart';
import '../../domain/usecases/get_timing_report_usecase.dart';

/// Drives the Timing Report bar chart: loads the current calendar month on
/// init (no search, no manual trigger — every day in the month is always
/// shown). The number of bars is always exactly [daysInMonth], computed
/// from the real calendar rather than hardcoded, so it's correct whichever
/// month is loaded (28 for Feb, 30 or 31 elsewhere).
class TimingReportController extends GetxController {
  TimingReportController(this._getTimingReportUseCase);

  final GetTimingReportUseCase _getTimingReportUseCase;

  final DateTime _now = DateTime.now();

  final RxList<TimingReportEntity> entries = <TimingReportEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  int get year => _now.year;

  int get month => _now.month;

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  @override
  void onInit() {
    super.onInit();
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
