import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/bag_completion_master_model.dart';
import 'bag_completion_master_data_source.dart';

/// Real-backend implementation — the only [BagCompletionMasterDataSource]
/// wired in by `BagCompletionBinding`; the Bag Completion ("Done") screen
/// always hits the live backend, no mock option.
///
/// `BagDoneDetail`'s response is a flat `status`/`message`/`data` object,
/// `status` as the string `"True"`/`"False"` — same convention as
/// `IssuedBagListNew`/`BagDetailsNew`.
class BagCompletionMasterRemoteDataSourceImpl implements BagCompletionMasterDataSource {
  BagCompletionMasterRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<BagCompletionMasterModel> getBagCompletionMaster({
    required String trnId,
    required String empCd,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.bagDoneDetail,
        data: {
          'trnId': trnId,
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load bag completion details');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const {};
      return BagCompletionMasterModel.fromApiJson(data);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load bag completion details', statusCode: e.response?.statusCode);
    }
  }
}
