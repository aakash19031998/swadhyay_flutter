import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/drawer_menu_item_model.dart';
import 'drawer_menu_data_source.dart';

/// Real-backend implementation, wired in whenever [AppConfig.useMockDrawerMenu]
/// is `false` (the default) — see [DrawerMenuDependencies].
///
/// `MenuListNew`'s response is a single flat object: `Status` ("True"/
/// "False", as a string, not a bool), `Message`, and `data` holding the
/// menu array directly.
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
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['Status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['Message'] as String? ?? 'Unable to load menu');
      }

      final List<dynamic> menuJson = body['data'] as List<dynamic>? ?? const [];
      return DrawerMenuItemModel.fromApiList(menuJson);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load menu', statusCode: e.response?.statusCode);
    }
  }
}
