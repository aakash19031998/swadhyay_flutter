import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/datasources/drawer_menu_data_source.dart';
import '../data/datasources/drawer_menu_remote_data_source_impl.dart';
import '../data/datasources/drawer_menu_static_data_source_impl.dart';
import '../data/repositories/drawer_menu_repository_impl.dart';
import '../domain/repositories/drawer_menu_repository.dart';

/// Registers [DrawerMenuRepository] once, mirroring [AuthDependencies].
class DrawerMenuDependencies {
  const DrawerMenuDependencies._();

  static void ensureRegistered() {
    if (Get.isRegistered<DrawerMenuRepository>()) return;

    Get.put<DrawerMenuDataSource>(
      AppConfig.useMockData
          ? DrawerMenuStaticDataSourceImpl()
          : DrawerMenuRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<DrawerMenuRepository>(
      DrawerMenuRepositoryImpl(Get.find<DrawerMenuDataSource>()),
      permanent: true,
    );
  }
}
