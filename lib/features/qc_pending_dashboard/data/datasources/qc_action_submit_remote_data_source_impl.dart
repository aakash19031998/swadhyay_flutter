import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/data_source_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/qc_repair_qty_entity.dart';
import '../../domain/entities/qc_submit_result_entity.dart';
import 'qc_action_submit_data_source.dart';

/// `BagFinalReceive`, submitted on the QC OK/Repair popup's Submit tap.
///
/// Unlike every other endpoint in this feature, a `status: false` response
/// here is a normal outcome to show the user (e.g. "already received"),
/// not a [ServerException] — only an actual `DioException` (network/server
/// failure) is treated as exceptional, so the caller can show `message` on
/// the app snackbar either way.
class QcActionSubmitRemoteDataSourceImpl implements QcActionSubmitDataSource {
  QcActionSubmitRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QcSubmitResultEntity> submit({
    required String action,
    required String trnId,
    required String bagNo,
    required String empCd,
    required String userEmpCd,
    required String process,
    required String diaQcCd,
    required List<QcRepairQtyEntity> repairList,
  }) {
    return wrapDioErrors(() async {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.bagFinalReceive,
        data: {
          'action': action,
          'trnId': trnId,
          'bagNo': bagNo,
          'empCd': empCd,
          'userEmpCd': userEmpCd,
          'process': process,
          'diaQcCd': diaQcCd,
          'repairList': [
            for (final entry in repairList) {'repairId': entry.repairId, 'qty': entry.qty},
          ],
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      final String message = body['message'] as String? ?? '';
      return QcSubmitResultEntity(success: status, message: message);
    }, (_) => 'Unable to submit');
  }
}
