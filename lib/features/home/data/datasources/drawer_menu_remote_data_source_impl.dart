import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/drawer_menu_item_model.dart';
import 'drawer_menu_data_source.dart';

/// Real-backend implementation, wired in whenever [AppConfig.useMockDrawerMenu]
/// is `false` (the default) — see [DrawerMenuDependencies].
///
/// `MenuListNew`'s payload is unusually double-wrapped: the top-level
/// `data` is a one-element list, and the actual menu array is that
/// element's own nested `data` field.
class DrawerMenuRemoteDataSourceImpl implements DrawerMenuDataSource {
  DrawerMenuRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<DrawerMenuItemModel>> getMenu(String empCd) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.menuListNew,
        data: {
          'empCd': empCd,
          // Unlike other endpoints' numeric appVersion, MenuListNew's
          // contract sends this field as a string.
          'appVersion': '1',
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      if (body['status'] != true) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load menu');
      }

      final List<dynamic> envelopes = body['data'] as List<dynamic>? ?? const [];
      if (envelopes.isEmpty) return const [];

      final List<dynamic> menuJson =
          (envelopes.first as Map<String, dynamic>)['data'] as List<dynamic>? ?? const [];
      return DrawerMenuItemModel.fromApiList(menuJson);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load menu', statusCode: e.response?.statusCode);
    }
  }
}
