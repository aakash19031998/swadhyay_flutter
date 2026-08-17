import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/sub_work_type_model.dart';
import 'sub_work_type_data_source.dart';

/// Real-backend implementation — the only [SubWorkTypeDataSource] wired in
/// by `BagCompletionBinding`. Called each time the user picks a Work Type,
/// to populate the Work dropdown with that Work Type's options.
///
/// `SubWorkType`'s response is a flat `status`/`message`/`data` object,
/// `status` as the string `"True"`/`"False"` — same convention as
/// `BagDoneDetail`/`IssuedBagListNew`.
class SubWorkTypeRemoteDataSourceImpl implements SubWorkTypeDataSource {
  SubWorkTypeRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SubWorkTypeModel>> getSubWorkTypes({
    required String schr,
    required String workType,
    required String empCd,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.subWorkType,
        data: {
          'schr': schr,
          'workType': workType,
          'empCode': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load work options');
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? const [];
      return [for (final item in data) SubWorkTypeModel.fromApiJson(item as Map<String, dynamic>)];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load work options', statusCode: e.response?.statusCode);
    }
  }
}
