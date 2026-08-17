import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'bag_done_submit_data_source.dart';

/// Real-backend implementation — the only [BagDoneSubmitDataSource] wired
/// in by `BagCompletionBinding`. Called on the Bag Completion screen's
/// Submit action, once the user confirms.
///
/// `BagDoneWithFirstReceive`'s response is just `status`/`message` (no
/// `data`), `status` as the string `"True"`/`"False"` — same convention as
/// every other endpoint here. A `"False"` status is a normal, valid
/// rejection (e.g. an invalid `proId`) to surface via `message`, not a
/// thrown [ServerException].
class BagDoneSubmitRemoteDataSourceImpl implements BagDoneSubmitDataSource {
  BagDoneSubmitRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({bool success, String message})> submit({
    required String trnId,
    required String proId,
    required String empCd,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.bagDoneWithFirstReceive,
        data: {
          'trnId': trnId,
          'proId': proId,
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool success = (body['status'] as String?)?.toLowerCase() == 'true';
      final String message = body['message'] as String? ?? '';

      return (success: success, message: message);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to submit work entry', statusCode: e.response?.statusCode);
    }
  }
}
