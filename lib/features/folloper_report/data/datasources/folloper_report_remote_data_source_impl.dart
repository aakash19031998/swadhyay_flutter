import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/folloper_report_model.dart';
import 'folloper_report_data_source.dart';

class FolloperReportRemoteDataSourceImpl implements FolloperReportDataSource {
  FolloperReportRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<FolloperReportModel>> getReport({String query = ''}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.folloperReport,
        queryParameters: {if (query.isNotEmpty) 'query': query},
      );
      return (response.data ?? [])
          .map((json) => FolloperReportModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load folloper report', statusCode: e.response?.statusCode);
    }
  }
}
