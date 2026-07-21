import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/drawer_menu_item_model.dart';
import 'drawer_menu_data_source.dart';

/// Future backend-driven implementation. Not used while
/// [AppConfig.useMockData] is `true` — kept fully implemented so making the
/// drawer menu dynamic later is a one-line [HomeBinding] change, not a
/// rewrite.
class DrawerMenuRemoteDataSourceImpl implements DrawerMenuDataSource {
  DrawerMenuRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  static const String _menuEndpoint = '/menu/drawer';

  @override
  Future<List<DrawerMenuItemModel>> getMenu() async {
    try {
      final Response<List<dynamic>> response = await _apiClient.get<List<dynamic>>(_menuEndpoint);
      return (response.data ?? [])
          .map((json) => DrawerMenuItemModel.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load menu', statusCode: e.response?.statusCode);
    }
  }
}
