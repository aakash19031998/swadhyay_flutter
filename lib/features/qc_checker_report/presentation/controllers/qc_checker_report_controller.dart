import 'package:get/get.dart';

import '../../../../core/base/date_range_report_controller.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/qc_checker_report_entity.dart';
import '../../domain/usecases/get_qc_checker_report_usecase.dart';

/// Drives the QC Checker Report screen — same "From/To date range + Show"
/// shape as `ArtistProductionController` (see [DateRangeReportController]
/// for the shared date/validation/loading state). The report call returns
/// both tables' rows plus the footer totals in one response, fanned out
/// into observables here.
class QcCheckerReportController extends DateRangeReportController {
  QcCheckerReportController(
    this._getQcCheckerReportUseCase,
    this._getCurrentEmployeeUseCase,
  );

  final GetQcCheckerReportUseCase _getQcCheckerReportUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;

  final RxList<QcPredictionScoreEntity> predictionScoreMatrix =
      <QcPredictionScoreEntity>[].obs;
  final RxList<QcShiftDistributionEntity> shiftProcessDistribution =
      <QcShiftDistributionEntity>[].obs;

  final RxDouble totalPointsValue = 0.0.obs;
  final RxInt totalBagPieces = 0.obs;
  final RxInt totalRepairCaught = 0.obs;
  final RxDouble ownRepairPoints = 0.0.obs;
  final RxInt ownRepairBags = 0.obs;
  final RxInt totalDayShiftBags = 0.obs;
  final RxInt totalEveningShiftBags = 0.obs;

  @override
  Future<void> fetchReport(DateTime from, DateTime to) async {
    final String? empCode = (await _getCurrentEmployeeUseCase())?.empCode;
    final result = await _getQcCheckerReportUseCase(
      fromDate: from,
      toDate: to,
      empCd: empCode ?? '',
    );
    result.fold((failure) => errorMessage.value = failure.message, (report) {
      totalPointsValue.value = report.totalPoints;
      totalBagPieces.value = report.totalBagPieces;
      totalRepairCaught.value = report.totalRepairCaught;
      ownRepairPoints.value = report.ownRepairPoints;
      ownRepairBags.value = report.ownRepairBags;
      totalDayShiftBags.value = report.totalDayShiftBags;
      totalEveningShiftBags.value = report.totalEveningShiftBags;
      predictionScoreMatrix.assignAll(report.predictionScoreMatrix);
      shiftProcessDistribution.assignAll(report.shiftProcessDistribution);
    });
  }
}
