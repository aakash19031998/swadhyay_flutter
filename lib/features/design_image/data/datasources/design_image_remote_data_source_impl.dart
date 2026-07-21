import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/design_image_model.dart';
import 'design_image_data_source.dart';

class DesignImageRemoteDataSourceImpl implements DesignImageDataSource {
  DesignImageRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<DesignImageModel>> getImages({String query = ''}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.designImages,
        queryParameters: {if (query.isNotEmpty) 'query': query},
      );
      return (response.data ?? [])
          .map((json) => DesignImageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load design images', statusCode: e.response?.statusCode);
    }
  }
}
