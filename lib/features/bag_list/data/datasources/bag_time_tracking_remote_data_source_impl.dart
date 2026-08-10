import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'bag_time_tracking_data_source.dart';

class BagTimeTrackingRemoteDataSourceImpl implements BagTimeTrackingDataSource {
  BagTimeTrackingRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({bool success, String message})> track({
    required String action,
    required int transactionId,
    required String bCoCo,
    required String byy,
    required String bchr,
    required int bNo,
    required int empCd,
    int? pauseReasonId,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.bagTimeTracking,
        data: {
          'action': action,
          'transactionId': transactionId,
          'bCoCo': bCoCo,
          'byy': byy,
          'bchr': bchr,
          'bNo': bNo,
          'empCd': empCd,
          'pauseReasonId': pauseReasonId,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      // Accepts either a JSON boolean (like `PauseReasonMaster`) or the
      // string `"True"`/`"False"` (like `IssuedBagListNew`/`BagDetailsNew`)
      // for `status` — this endpoint's exact convention wasn't confirmed,
      // so both of this app's existing conventions are handled rather than
      // guessing one and breaking silently on the other.
      final dynamic rawStatus = body['status'];
      final bool success = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      final String message = body['message'] as String? ?? '';

      return (success: success, message: message);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to update bag status', statusCode: e.response?.statusCode);
    }
  }
}
