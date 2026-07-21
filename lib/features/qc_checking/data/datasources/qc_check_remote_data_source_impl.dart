import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/qc_check_model.dart';
import 'qc_check_data_source.dart';

class QcCheckRemoteDataSourceImpl implements QcCheckDataSource {
  QcCheckRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<QcCheckModel>> getChecks({String query = ''}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.qcChecking,
        queryParameters: {if (query.isNotEmpty) 'query': query},
      );
      return (response.data ?? []).map((json) => QcCheckModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load QC checks', statusCode: e.response?.statusCode);
    }
  }
}
