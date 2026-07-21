import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/bag_model.dart';
import 'bag_data_source.dart';

class BagRemoteDataSourceImpl implements BagDataSource {
  BagRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<BagModel>> getBags({String query = ''}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.bagList,
        queryParameters: {if (query.isNotEmpty) 'query': query},
      );
      return (response.data ?? []).map((json) => BagModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load bag list', statusCode: e.response?.statusCode);
    }
  }
}
