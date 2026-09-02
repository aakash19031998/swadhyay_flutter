import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/data_source_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/qc_assigned_bag_model.dart';
import 'qc_bag_list_data_source.dart';

/// `QcPendingBagList`, called with `empCd`+`appVersion` (POST) — `empCd` is
/// the employee selected on the QC Checker Emp List screen.
class QcBagListRemoteDataSourceImpl implements QcBagListDataSource {
  QcBagListRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<QcAssignedBagModel>> getBagList({required String empCd}) {
    return wrapDioErrors(() async {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.qcPendingBagList,
        data: {
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load bag list');
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? const [];
      return [
        for (final entry in data) QcAssignedBagModel.fromJson(entry as Map<String, dynamic>),
      ];
    }, (_) => 'Unable to load bag list');
  }
}
