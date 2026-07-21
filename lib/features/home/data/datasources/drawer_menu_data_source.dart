import '../models/drawer_menu_item_model.dart';

/// Data-source contract for the drawer menu. [DrawerMenuStaticDataSourceImpl]
/// is the V1 implementation (hardcoded tree); [DrawerMenuRemoteDataSourceImpl]
/// is ready for when the menu becomes backend-driven — swapping which one
/// [HomeBinding] wires in is the only change required.
abstract class DrawerMenuDataSource {
  Future<List<DrawerMenuItemModel>> getMenu();
}
