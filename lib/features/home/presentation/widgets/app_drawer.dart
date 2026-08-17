import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/drawer_expansion_tile.dart';
import '../../../../core/widgets/drawer_tile.dart';
import '../../../../core/widgets/profile_card.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';
import '../controllers/home_controller.dart';

/// The app's navigation drawer: [ProfileCard] header followed by the
/// reactive menu tree from [HomeController.menuItems].
class AppDrawer extends GetView<HomeController> {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isPhone = screenWidth < AppDimensions.breakpointPhone;
    final double fraction =
        isPhone ? AppDimensions.drawerPhoneWidthFraction : AppDimensions.drawerTabletWidthFraction;
    final double drawerWidth =
        (screenWidth * fraction).clamp(AppDimensions.drawerMinWidth, AppDimensions.drawerMaxWidth);

    return Drawer(
      width: drawerWidth,
      child: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final employee = controller.employee.value;
              return InkWell(
                onTap: employee == null ? null : controller.onProfileTap,
                child: ProfileCard(
                  name: employee?.name ?? '',
                  empCode: employee?.empCode ?? '',
                  department: employee?.department,
                  avatarUrl: employee?.avatarUrl,
                  inTimeLabel: employee?.punchInAt == null
                      ? null
                      : DateTimeHelper.formatDateTime(employee!.punchInAt!),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isMenuLoading.value) return const AppLoader();
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: controller.menuItems.map(_buildItem).toList(),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingXs,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'v${AppVersion.versionName}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(DrawerMenuItemEntity item) {
    if (item.type == DrawerMenuItemType.group) {
      return DrawerExpansionTile(
        icon: item.icon,
        label: item.label,
        initiallyExpanded: false,
        children: item.children.map(_buildLeaf).toList(),
      );
    }
    return _buildLeaf(item);
  }

  Widget _buildLeaf(DrawerMenuItemEntity item) {
    return DrawerTile(
      icon: item.icon,
      label: item.label,
      selected: item.route != null && item.route == Get.currentRoute,
      onTap: () => controller.onMenuItemTap(item),
    );
  }
}
