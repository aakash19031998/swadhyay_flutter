import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/bag_model.dart';
import 'bag_data_source.dart';

/// Real-backend implementation, wired in whenever [AppConfig.useMockBagList]
/// is `false` (the default) — see [BagListBinding].
///
/// `IssuedBagListNew` has no server-side search — it always returns every
/// issued bag for [empCd]. Search is applied client-side in
/// `BagListController` against a snapshot of this full list, not per-call
/// here, so a fetch only ever happens on an explicit (re)load, never once
/// per keystroke. `bag_count`/`pcs_count` are the server's own totals for
/// that same full list.
class BagRemoteDataSourceImpl implements BagDataSource {
  BagRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({int bagCount, int pcsCount, List<BagModel> bags})> getBags({required String empCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.issuedBagListNew,
        data: {
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load bag list');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const {};
      final int bagCount = (data['bag_count'] as num?)?.toInt() ?? 0;
      final int pcsCount = (data['pcs_count'] as num?)?.toInt() ?? 0;
      final List<dynamic> bagListJson = data['bag_list'] as List<dynamic>? ?? const [];

      final List<BagModel> bags = bagListJson
          .map((json) => BagModel.fromApiJson(json as Map<String, dynamic>))
          .toList(growable: false);

      return (bagCount: bagCount, pcsCount: pcsCount, bags: bags);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load bag list', statusCode: e.response?.statusCode);
    }
  }
}
