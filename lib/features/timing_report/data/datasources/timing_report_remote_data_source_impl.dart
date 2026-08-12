import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/timing_report_model.dart';
import 'timing_report_data_source.dart';

/// `ArtistTimeUtilizationReport`'s response is a flat `status`/`message`/
/// `data` object. The sample contract had `status` as a JSON boolean (same
/// convention as `PauseReasonMaster`), but the live backend actually sends
/// it as a string like most other endpoints — accepts either form instead
/// of assuming one and crashing on the other (same defensive parsing as
/// `BagTimeTracking`). The endpoint is scoped by employee only (no
/// year/month request params), so it always returns this employee's full
/// available history in one call.
class TimingReportRemoteDataSourceImpl implements TimingReportDataSource {
  TimingReportRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TimingReportModel>> getReport({required String empCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.timingReport,
        data: {'empCd': int.tryParse(empCd) ?? 0},
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load timing report');
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? const [];
      return [for (final entry in data) TimingReportModel.fromJson(entry as Map<String, dynamic>)];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load timing report', statusCode: e.response?.statusCode);
    }
  }
}
