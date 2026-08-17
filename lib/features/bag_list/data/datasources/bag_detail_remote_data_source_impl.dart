import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/raw_json_numbers.dart';
import '../../../../core/network/api_client.dart';
import '../models/bag_detail_model.dart';
import 'bag_detail_data_source.dart';

/// Real-backend implementation — the only [BagDetailDataSource] wired in by
/// [BagDetailBinding]; the Bag Detail screen always hits the live backend,
/// no mock option.
///
/// `BagDetailsNew`'s response is a single flat `status`/`message`/`data`
/// object (like `IssuedBagListNew`, `status` as a string, not a bool) whose
/// `data.bag_Detail` holds the Bag Summary/Manufacturing Instructions
/// fields, `data.diamondDetails` holds the Diamond Details rows, and
/// `data.rmSummary` holds the Bag RM Summary rows — all three siblings of
/// each other under `data`.
///
/// The response is fetched as plain text (not auto-decoded) so
/// [RawJsonNumbers] can pull the Diamond Details/Bag RM Summary numeric
/// columns straight out of the raw body before `jsonDecode` gets a chance to
/// collapse their exact formatting (e.g. "1.4000") down to a `double`.
class BagDetailRemoteDataSourceImpl implements BagDetailDataSource {
  BagDetailRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<BagDetailModel> getBagDetail({required String bagNo, required String empCd}) async {
    try {
      final Response<String> response = await _apiClient.post<String>(
        ApiEndpoints.bagDetailsNew,
        data: {
          'bno': bagNo,
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
        options: Options(responseType: ResponseType.plain),
      );

      final String raw = response.data ?? '';
      final Map<String, dynamic> body = jsonDecode(raw) as Map<String, dynamic>;
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load bag details');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const {};
      final Map<String, dynamic>? bagDetail = data['bag_Detail'] as Map<String, dynamic>?;
      if (bagDetail == null) {
        throw const ServerException(message: 'Malformed bag detail response');
      }
      final List<dynamic> diamondDetailsJson = data['diamondDetails'] as List<dynamic>? ?? const [];
      final List<dynamic> rmSummaryJson = data['rmSummary'] as List<dynamic>? ?? const [];

      return BagDetailModel.fromApiJson(
        bagDetail,
        diamondDetailsJson: diamondDetailsJson,
        rmSummaryJson: rmSummaryJson,
        rawWeights: RawJsonNumbers.extract(raw, 'weight'),
        rawCurrentQty: RawJsonNumbers.extract(raw, 'CurrentQty'),
        rawWt: RawJsonNumbers.extract(raw, 'Wt'),
      );
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load bag details', statusCode: e.response?.statusCode);
    }
  }
}
