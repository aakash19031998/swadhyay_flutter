import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/data_source_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../qc_pending_dashboard/data/models/qc_assigned_bag_model.dart';
import 'qc_checker_bag_search_data_source.dart';

/// `QCPendingBagSingle`, called with `bagBarcode`+`appVersion` (POST) — the
/// QC Checker screen's "Show"/scan search, looking a bag up by its scanned
/// barcode rather than by employee (see `QcBagListRemoteDataSourceImpl`'s
/// `QcPendingBagList`, which this feature doesn't use). The response shape
/// matches `QcPendingBagList`'s entries exactly, so the same
/// `QcAssignedBagModel.fromJson` is reused to parse them.
class QcCheckerBagSearchRemoteDataSourceImpl
    implements QcCheckerBagSearchDataSource {
  QcCheckerBagSearchRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<QcAssignedBagModel>> searchBag({
    required String bagBarcode,
  }) {
    return wrapDioErrors(() async {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.qcPendingBagSingle,
            data: {
              'bagBarcode': bagBarcode,
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
          message: body['message'] as String? ?? 'Unable to load bag',
        );
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? const [];
      return [
        for (final entry in data)
          QcAssignedBagModel.fromJson(entry as Map<String, dynamic>),
      ];
    }, (_) => 'Unable to load bag');
  }
}
