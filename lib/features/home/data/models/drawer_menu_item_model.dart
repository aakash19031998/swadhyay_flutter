import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';

/// Maps the small set of icon names the backend is allowed to send to a
/// concrete [IconData]. Keeps [DrawerMenuRemoteDataSourceImpl] able to
/// build [DrawerMenuItemEntity] trees from JSON without the domain/
/// presentation layers ever knowing icons came from a string.
const Map<String, IconData> _iconRegistry = {
  'bag': Icons.shopping_bag_outlined,
  'password': Icons.lock_outline,
  'reports': Icons.assessment_outlined,
  'design_image': Icons.image_outlined,
  'qc_checking': Icons.fact_check_outlined,
  'qc_checker': Icons.qr_code_scanner_outlined,
  'timing_report': Icons.timer_outlined,
  'artist_production': Icons.brush_outlined,
  'logout': Icons.logout,
  'dashboard': Icons.dashboard_outlined,
};

class _MenuMeta {
  const _MenuMeta(this.icon, this.route);

  final IconData icon;
  final String? route;
}

/// `MenuListNew`'s `MenuName` -> icon/route, matched case-insensitively.
/// This is how a menu entry's screen is resolved: by its name, not by an id
/// the backend doesn't send. Group entries (e.g. "Reports") have no route
/// of their own — their `SubMenuList` children carry the routes instead.
/// Any name absent from this table renders with a placeholder icon and no
/// route (tapping it does nothing), so an unrecognized backend entry never
/// crashes the app.
final Map<String, _MenuMeta> _menuMetaByName = {
  'bag list': const _MenuMeta(Icons.shopping_bag_outlined, AppRoutes.bagList),
  'design image': const _MenuMeta(Icons.image_outlined, AppRoutes.designImage),
  // "Qc Checking" is the current live MenuListNew entry's name — it now
  // opens the new QC Checker screen, not the renamed QC Pending Dashboard.
  // "QC Pending Dashboard" is a distinct, not-yet-added menu option (see
  // AppStrings.qcPendingDashboard) that will route to that screen once the
  // backend sends it.
  'qc checking': const _MenuMeta(
    Icons.qr_code_scanner_outlined,
    AppRoutes.qcChecker,
  ),
  'qc pending dashboard': const _MenuMeta(
    Icons.fact_check_outlined,
    AppRoutes.qcPendingDashboard,
  ),
  'qc checker': const _MenuMeta(
    Icons.qr_code_scanner_outlined,
    AppRoutes.qcChecker,
  ),
  'reports': const _MenuMeta(Icons.assessment_outlined, null),
  'timing report': const _MenuMeta(
    Icons.timer_outlined,
    AppRoutes.timingReport,
  ),
  'artist production': const _MenuMeta(
    Icons.brush_outlined,
    AppRoutes.artistProduction,
  ),
  'qc checker report': const _MenuMeta(
    Icons.query_stats_outlined,
    AppRoutes.qcCheckerReport,
  ),
  'change password': const _MenuMeta(
    Icons.lock_outline,
    AppRoutes.changePassword,
  ),
  'brand specification': const _MenuMeta(
    Icons.storefront_outlined,
    AppRoutes.brandSpecification,
  ),
};

const _MenuMeta _unknownMenuMeta = _MenuMeta(Icons.circle_outlined, null);

class DrawerMenuItemModel extends DrawerMenuItemEntity {
  const DrawerMenuItemModel({
    required super.id,
    required super.label,
    required super.icon,
    required super.type,
    super.route,
    super.actionKey,
    super.children,
  });

  factory DrawerMenuItemModel.fromJson(Map<String, dynamic> json) {
    return DrawerMenuItemModel(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: _iconRegistry[json['icon'] as String] ?? Icons.circle_outlined,
      type: DrawerMenuItemType.values.byName(json['type'] as String),
      route: json['route'] as String?,
      actionKey: json['actionKey'] as String?,
      children: (json['children'] as List<dynamic>? ?? [])
          .map(
            (child) =>
                DrawerMenuItemModel.fromJson(child as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  /// Parses one `MenuListNew` entry (top-level or from `SubMenuList`).
  /// `MenuType`/`SubMenuList` are only present on top-level entries — absent
  /// on sub-menu entries, which default to a leaf/link.
  factory DrawerMenuItemModel.fromApiJson(Map<String, dynamic> json) {
    final String name = (json['MenuName'] as String?)?.trim() ?? '';
    final bool isGroup = (json['MenuType'] as String?) == 'DropDown';
    final _MenuMeta meta =
        _menuMetaByName[name.toLowerCase()] ?? _unknownMenuMeta;
    final List<dynamic> subMenu =
        json['SubMenuList'] as List<dynamic>? ?? const [];

    return DrawerMenuItemModel(
      id: 'menu_${json['MenuId']}',
      label: name,
      icon: meta.icon,
      type: isGroup ? DrawerMenuItemType.group : DrawerMenuItemType.link,
      route: isGroup ? null : meta.route,
      children: isGroup ? fromApiList(subMenu) : const [],
    );
  }

  /// Parses a `MenuListNew` menu array: drops entries with `MenuValidSts !=
  /// "Y"` and orders by `MenuSortBy`, since the backend does not guarantee
  /// either.
  static List<DrawerMenuItemModel> fromApiList(List<dynamic> json) {
    final List<Map<String, dynamic>> visible =
        json
            .cast<Map<String, dynamic>>()
            .where(
              (item) => (item['MenuValidSts'] as String?)?.toUpperCase() == 'Y',
            )
            .toList()
          ..sort(
            (a, b) => ((a['MenuSortBy'] as num?) ?? 0).compareTo(
              (b['MenuSortBy'] as num?) ?? 0,
            ),
          );
    return visible.map(DrawerMenuItemModel.fromApiJson).toList(growable: false);
  }
}
