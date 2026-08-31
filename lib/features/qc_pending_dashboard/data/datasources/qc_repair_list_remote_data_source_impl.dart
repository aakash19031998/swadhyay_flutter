import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/qc_repair_checklist_item_model.dart';
import 'qc_repair_list_data_source.dart';

/// `QCRepairList`, called with `schr`+`empCd`+`appVersion` (POST) — `schr`
/// is the tapped bag's `Process`, `empCd` is the selected employee's code.
///
/// The response also carries a `DiaQcList`, but the "Diamond QC Checker"
/// master list is now sourced centrally from `DeptQCPendingEmpList` instead
/// (see `QcEmpListRemoteDataSourceImpl`), so it's ignored here.
class QcRepairListRemoteDataSourceImpl implements QcRepairListDataSource {
  QcRepairListRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<QcRepairChecklistItemModel>> getRepairList({required String schr, required String empCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.qcRepairList,
        data: {
          'schr': schr,
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load repair list');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final List<dynamic> repairJson = data['RepairList'] as List<dynamic>? ?? const [];

      return [
        for (final entry in repairJson) QcRepairChecklistItemModel.fromJson(entry as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load repair list', statusCode: e.response?.statusCode);
    }
  }
}
