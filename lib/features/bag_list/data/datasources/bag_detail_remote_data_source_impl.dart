import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/bag_detail_model.dart';
import 'bag_detail_data_source.dart';

/// Real-backend implementation — the only [BagDetailDataSource] wired in by
/// [BagDetailBinding]; the Bag Detail screen always hits the live backend,
/// no mock option.
///
/// `BagDetailsNew`'s response is a single flat `status`/`message`/`data`
/// object (like `IssuedBagListNew`, `status` as a string, not a bool) whose
/// `data.bag_Detail` holds the actual fields.
class BagDetailRemoteDataSourceImpl implements BagDetailDataSource {
  BagDetailRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<BagDetailModel> getBagDetail({required String bagNo, required String empCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.bagDetailsNew,
        data: {
          'bno': bagNo,
          'empCd': empCd,
          // Fixed literal per this endpoint's contract, not a real version.
          'appVersion': '1',
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load bag details');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const {};
      final Map<String, dynamic>? bagDetail = data['bag_Detail'] as Map<String, dynamic>?;
      if (bagDetail == null) {
        throw const ServerException(message: 'Malformed bag detail response');
      }

      return BagDetailModel.fromApiJson(bagDetail);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load bag details', statusCode: e.response?.statusCode);
    }
  }
}
