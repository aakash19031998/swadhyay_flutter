import 'package:flutter/material.dart';

import '../../domain/entities/drawer_menu_item_entity.dart';

/// Maps the small set of icon names the backend is allowed to send to a
/// concrete [IconData]. Keeps [DrawerMenuRemoteDataSourceImpl] able to
/// build [DrawerMenuItemEntity] trees from JSON without the domain/
/// presentation layers ever knowing icons came from a string.
const Map<String, IconData> _iconRegistry = {
  'bag': Icons.shopping_bag_outlined,
  'skip_next': Icons.skip_next_outlined,
  'password': Icons.lock_outline,
  'reports': Icons.assessment_outlined,
  'design_image': Icons.image_outlined,
  'qc_checking': Icons.fact_check_outlined,
  'timing_report': Icons.timer_outlined,
  'artist_production': Icons.brush_outlined,
  'folloper_report': Icons.groups_outlined,
  'logout': Icons.logout,
  'dashboard': Icons.dashboard_outlined,
};

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
          .map((child) => DrawerMenuItemModel.fromJson(child as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
