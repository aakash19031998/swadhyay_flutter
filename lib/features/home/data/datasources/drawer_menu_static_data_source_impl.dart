import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';
import '../models/drawer_menu_item_model.dart';
import 'drawer_menu_data_source.dart';

/// V1 hardcoded menu tree, matching the approved reference design exactly:
/// Bag List, Skip Bag, Change Password, Reports (Design Image, Qc Checking,
/// Timing Report, Artist Production, Folloper Report), Logout.
class DrawerMenuStaticDataSourceImpl implements DrawerMenuDataSource {
  @override
  Future<List<DrawerMenuItemModel>> getMenu(String empCd) async {
    await Future.delayed(AppConfig.mockLatency);

    return const [
      DrawerMenuItemModel(
        id: 'bag_list',
        label: AppStrings.bagList,
        icon: Icons.shopping_bag_outlined,
        type: DrawerMenuItemType.link,
        route: AppRoutes.bagList,
      ),
      DrawerMenuItemModel(
        id: 'skip_bag',
        label: AppStrings.skipBag,
        icon: Icons.skip_next_outlined,
        type: DrawerMenuItemType.link,
        route: AppRoutes.skipBag,
      ),
      DrawerMenuItemModel(
        id: 'change_password',
        label: AppStrings.changePassword,
        icon: Icons.lock_outline,
        type: DrawerMenuItemType.link,
        route: AppRoutes.changePassword,
      ),
      DrawerMenuItemModel(
        id: 'reports',
        label: AppStrings.reports,
        icon: Icons.assessment_outlined,
        type: DrawerMenuItemType.group,
        children: [
          DrawerMenuItemModel(
            id: 'design_image',
            label: AppStrings.designImage,
            icon: Icons.image_outlined,
            type: DrawerMenuItemType.link,
            route: AppRoutes.designImage,
          ),
          DrawerMenuItemModel(
            id: 'qc_checking',
            label: AppStrings.qcChecking,
            icon: Icons.fact_check_outlined,
            type: DrawerMenuItemType.link,
            route: AppRoutes.qcChecking,
          ),
          DrawerMenuItemModel(
            id: 'timing_report',
            label: AppStrings.timingReport,
            icon: Icons.timer_outlined,
            type: DrawerMenuItemType.link,
            route: AppRoutes.timingReport,
          ),
          DrawerMenuItemModel(
            id: 'artist_production',
            label: AppStrings.artistProduction,
            icon: Icons.brush_outlined,
            type: DrawerMenuItemType.link,
            route: AppRoutes.artistProduction,
          ),
          DrawerMenuItemModel(
            id: 'folloper_report',
            label: AppStrings.folloperReport,
            icon: Icons.groups_outlined,
            type: DrawerMenuItemType.link,
            route: AppRoutes.folloperReport,
          ),
        ],
      ),
      DrawerMenuItemModel(
        id: 'logout',
        label: AppStrings.logout,
        icon: Icons.logout,
        type: DrawerMenuItemType.action,
        actionKey: 'logout',
      ),
    ];
  }
}
