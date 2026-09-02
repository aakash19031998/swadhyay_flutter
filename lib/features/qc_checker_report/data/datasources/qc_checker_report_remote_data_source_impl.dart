import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/data_source_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/qc_checker_report_entity.dart';
import 'qc_checker_report_data_source.dart';

/// `QcCheckingReport`, called with `frmDt`/`toDt`/`qcEmpCd`/`appVersion`
/// (POST). `data.QcSummary` feeds the Prediction Score Matrix table,
/// `data.QcDetail` feeds the Shift & Process Distribution table.
///
/// Both arrays include the API's own aggregate row(s) — `QcSummary`'s
/// `"Total :-"` row (empty `Process`/`Prediction`) and `QcDetail`'s `"--"`
/// grand-total row (empty `EmpCode`) — which are dropped here rather than
/// shown as ordinary rows, since the screen computes its own footer totals
/// by summing the real rows (a `QcDetail` `"Own Repair"` adjustment row,
/// which has a non-empty `EmpCode`, is kept as an ordinary row).
class QcCheckerReportRemoteDataSourceImpl implements QcCheckerReportDataSource {
  QcCheckerReportRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QcCheckerReportEntity> getReport({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  }) {
    return wrapDioErrors(() async {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.qcCheckingReport,
            data: {
              'frmDt': DateTimeHelper.formatApiDate(fromDate),
              'toDt': DateTimeHelper.formatApiDate(toDate),
              'qcEmpCd': empCd,
              'appVersion': AppVersion.versionName,
            },
          );

      final Map<String, dynamic> body =
          response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool
          ? rawStatus
          : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(
          message:
              body['message'] as String? ?? 'Unable to load QC checker report',
        );
      }

      final Map<String, dynamic> data =
          body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};

      final List<dynamic> summaryJson =
          data['QcSummary'] as List<dynamic>? ?? const [];
      final List<QcPredictionScoreEntity> predictionScoreMatrix = [
        for (final entry in summaryJson)
          if (((entry as Map<String, dynamic>)['Process'] as String?)
                  ?.trim()
                  .isNotEmpty ??
              false)
            QcPredictionScoreEntity(
              process: entry['Process'] as String? ?? '',
              prediction: entry['Prediction'] as String? ?? '',
              totalPoints: (entry['TotalPoints'] as num?)?.toDouble() ?? 0,
              repairCaught: (entry['RepairCaughtByYou'] as num?)?.toInt() ?? 0,
            ),
      ];
      final double totalPoints = predictionScoreMatrix.fold(
        0,
        (sum, item) => sum + item.totalPoints,
      );
      final int totalRepairCaught = predictionScoreMatrix.fold(
        0,
        (sum, item) => sum + item.repairCaught,
      );

      final List<dynamic> detailJson =
          data['QcDetail'] as List<dynamic>? ?? const [];
      final List<QcShiftDistributionEntity> shiftProcessDistribution = [
        for (final entry in detailJson)
          if (((entry as Map<String, dynamic>)['EmpCode'] as String?)
                  ?.trim()
                  .isNotEmpty ??
              false)
            QcShiftDistributionEntity(
              process: entry['Process'] as String? ?? '',
              emrBag: (entry['EmrBagPieces'] as num?)?.toInt() ?? 0,
              points: (entry['TotalPoints'] as num?)?.toDouble() ?? 0,
              repair: (entry['Repair'] as num?)?.toInt() ?? 0,
              dayShiftBags: (entry['Shift1Pcs'] as num?)?.toInt() ?? 0,
              eveningShiftBags: (entry['Shift2Pcs'] as num?)?.toInt() ?? 0,
            ),
      ];
      final int totalDayShiftBags = shiftProcessDistribution.fold(
        0,
        (sum, item) => sum + item.dayShiftBags,
      );
      final int totalEveningShiftBags = shiftProcessDistribution.fold(
        0,
        (sum, item) => sum + item.eveningShiftBags,
      );

      // The `"Own Repair"` row is a deduction/adjustment, not a real
      // per-process entry — surfaced separately (see [ownRepairPoints]/
      // [ownRepairBags]) rather than folded into [totalBagPieces].
      bool isOwnRepair(QcShiftDistributionEntity item) =>
          item.process.trim().toLowerCase() == 'own repair';
      final QcShiftDistributionEntity? ownRepair = shiftProcessDistribution
          .cast<QcShiftDistributionEntity?>()
          .firstWhere((item) => isOwnRepair(item!), orElse: () => null);
      final int totalBagPieces = shiftProcessDistribution
          .where((item) => !isOwnRepair(item))
          .fold(0, (sum, item) => sum + item.emrBag);

      return QcCheckerReportEntity(
        totalPoints: totalPoints,
        totalBagPieces: totalBagPieces,
        totalRepairCaught: totalRepairCaught,
        ownRepairPoints: ownRepair?.points ?? 0,
        ownRepairBags: ownRepair?.emrBag ?? 0,
        totalDayShiftBags: totalDayShiftBags,
        totalEveningShiftBags: totalEveningShiftBags,
        predictionScoreMatrix: predictionScoreMatrix,
        shiftProcessDistribution: shiftProcessDistribution,
      );
    }, (_) => 'Unable to load QC checker report');
  }
}
