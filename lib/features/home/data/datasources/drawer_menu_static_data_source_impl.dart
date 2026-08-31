import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';
import '../models/drawer_menu_item_model.dart';
import 'drawer_menu_data_source.dart';

/// V1 hardcoded menu tree: Bag List, Change Password, Brand Specification,
/// QC Pending Dashboard, QC Checker, Reports (Design Image, Timing Report,
/// Artist Production), Logout. Brand Specification, QC Pending Dashboard and
/// QC Checker are top-level items (not nested under Reports) — plain
/// standalone tiles, the same as Logout, rather than reachable only by
/// expanding that group.
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
        id: 'change_password',
        label: AppStrings.changePassword,
        icon: Icons.lock_outline,
        type: DrawerMenuItemType.link,
        route: AppRoutes.changePassword,
      ),
      DrawerMenuItemModel(
        id: 'brand_specification',
        label: AppStrings.brandSpecification,
        icon: Icons.storefront_outlined,
        type: DrawerMenuItemType.link,
        route: AppRoutes.brandSpecification,
      ),
      DrawerMenuItemModel(
        id: 'qc_pending_dashboard',
        label: AppStrings.qcPendingDashboard,
        icon: Icons.fact_check_outlined,
        type: DrawerMenuItemType.link,
        route: AppRoutes.qcPendingDashboard,
      ),
      DrawerMenuItemModel(
        id: 'qc_checker',
        label: AppStrings.qcChecker,
        icon: Icons.qr_code_scanner_outlined,
        type: DrawerMenuItemType.link,
        route: AppRoutes.qcChecker,
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
