import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/pause_reason_model.dart';
import 'pause_reason_data_source.dart';

/// Real-backend implementation, wired in whenever
/// [AppConfig.useMockPauseReason] is `false` (the default).
///
/// Unlike every other endpoint in this app, `PauseReasonMaster`'s `status`
/// is a JSON **boolean** (`true`/`false`), not the string `"True"`/`"False"`
/// `IssuedBagListNew`/`BagDetailsNew`/etc. all use — parsed accordingly here,
/// not with the usual `.toLowerCase() == 'true'` string check.
class PauseReasonRemoteDataSourceImpl implements PauseReasonDataSource {
  PauseReasonRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PauseReasonModel>> getReasons() async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.pauseReasonMaster,
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = body['status'] as bool? ?? false;
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load pause reasons');
      }

      final List<dynamic> reasonsJson = body['data'] as List<dynamic>? ?? const [];
      return [
        for (final entry in reasonsJson) PauseReasonModel.fromJson(entry as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load pause reasons', statusCode: e.response?.statusCode);
    }
  }
}
