import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_production_model.dart';
import 'artist_production_data_source.dart';

/// `ArtistProductionRpt`'s response is a flat `status`/`message`/`data`
/// object (`status` as a string), whose `data` holds the till-date KPI
/// totals alongside the `detail`/`summary` row arrays as siblings.
class ArtistProductionRemoteDataSourceImpl implements ArtistProductionDataSource {
  ArtistProductionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ArtistProductionReportModel> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.artistProduction,
        data: {
          'frDt': DateTimeHelper.formatApiDate(fromDate),
          'toDt': DateTimeHelper.formatApiDate(toDate),
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load artist production');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const {};
      return ArtistProductionReportModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load artist production', statusCode: e.response?.statusCode);
    }
  }
}
