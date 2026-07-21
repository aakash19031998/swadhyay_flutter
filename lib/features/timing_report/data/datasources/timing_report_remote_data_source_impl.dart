import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/timing_report_model.dart';
import 'timing_report_data_source.dart';

class TimingReportRemoteDataSourceImpl implements TimingReportDataSource {
  TimingReportRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TimingReportModel>> getReport({required int year, required int month}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(
        ApiEndpoints.timingReport,
        queryParameters: {'year': year, 'month': month},
      );
      return (response.data ?? [])
          .map((json) => TimingReportModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load timing report', statusCode: e.response?.statusCode);
    }
  }
}
