import 'package:get/get.dart';

import '../../../../core/base/date_range_report_controller.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/artist_production_entity.dart';
import '../../domain/usecases/get_artist_production_usecase.dart';

/// Drives the Artist Production Report screen: a From/To date range and a
/// "Show" action to re-run it (see [DateRangeReportController] for the
/// shared date/validation/loading state). `ArtistProductionRpt` returns the
/// till-date KPI totals and both the detail/summary rows in one call, so
/// [fetchReport] fans a single response out into all five observables
/// instead of deriving the summary client-side.
class ArtistProductionController extends DateRangeReportController {
  ArtistProductionController(this._getArtistProductionUseCase, this._getCurrentEmployeeUseCase);

  final GetArtistProductionUseCase _getArtistProductionUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;

  final RxList<ArtistProductionDetailEntity> items = <ArtistProductionDetailEntity>[].obs;
  final RxList<ArtistProductionSummaryEntity> summary = <ArtistProductionSummaryEntity>[].obs;

  final RxInt totalPieces = 0.obs;
  final RxInt totalParts = 0.obs;
  final RxDouble totalPointsValue = 0.0.obs;

  @override
  Future<void> fetchReport(DateTime from, DateTime to) async {
    final String? empCode = (await _getCurrentEmployeeUseCase())?.empCode;
    final result = await _getArtistProductionUseCase(
      fromDate: from,
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
  }
}
