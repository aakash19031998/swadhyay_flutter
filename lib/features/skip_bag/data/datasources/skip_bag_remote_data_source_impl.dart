import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/skipped_bag_model.dart';
import 'skip_bag_data_source.dart';

class SkipBagRemoteDataSourceImpl implements SkipBagDataSource {
  SkipBagRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SkippedBagModel>> getSkippedBags({String query = ''}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.skipBag,
        queryParameters: {if (query.isNotEmpty) 'query': query},
      );
      return (response.data ?? [])
          .map((json) => SkippedBagModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load skipped bags', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<SkippedBagModel> skipBag({required String bagNo, required String reason}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.skipBag,
        data: {'bagNo': bagNo, 'reason': reason},
      );
      return SkippedBagModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? 'Unable to skip bag',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
