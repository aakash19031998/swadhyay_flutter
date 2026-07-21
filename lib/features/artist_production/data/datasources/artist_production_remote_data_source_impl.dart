import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_production_model.dart';
import 'artist_production_data_source.dart';

class ArtistProductionRemoteDataSourceImpl implements ArtistProductionDataSource {
  ArtistProductionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ArtistProductionModel>> getProduction({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.artistProduction,
        queryParameters: {
          'fromDate': fromDate.toIso8601String(),
          'toDate': toDate.toIso8601String(),
        },
      );
      return (response.data ?? [])
          .map((json) => ArtistProductionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load artist production', statusCode: e.response?.statusCode);
    }
  }
}
