import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/design_master_model.dart';
import 'design_master_data_source.dart';

class DesignMasterRemoteDataSourceImpl implements DesignMasterDataSource {
  DesignMasterRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DesignMasterModel?> getDesignMaster({required String styleNo}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.designMaster,
        queryParameters: {'styleNo': styleNo},
      );
      final Map<String, dynamic>? data = response.data;
      if (data == null || data.isEmpty) return null;
      return DesignMasterModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerException(message: 'Unable to load design details', statusCode: e.response?.statusCode);
    }
  }
}
