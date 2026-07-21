import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// How tapping a [DrawerMenuItemEntity] should be handled by the view.
enum DrawerMenuItemType {
  /// Navigates to [DrawerMenuItemEntity.route].
  link,

  /// Renders an expandable group of [DrawerMenuItemEntity.children].
  group,

  /// Triggers [DrawerMenuItemEntity.actionKey] instead of navigating.
  action,
}

/// A single navigation-drawer entry.
///
/// The menu is static for V1 (see [GetDrawerMenuUseCase]/
/// [DrawerMenuStaticDataSourceImpl]), but the view only ever renders this
/// entity tree — swapping in [DrawerMenuRemoteDataSourceImpl] later changes
/// nothing in `HomeView`.
class DrawerMenuItemEntity extends Equatable {
  const DrawerMenuItemEntity({
    required this.id,
    required this.label,
    required this.icon,
    required this.type,
    this.route,
    this.actionKey,
    this.children = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final DrawerMenuItemType type;
  final String? route;
  final String? actionKey;
  final List<DrawerMenuItemEntity> children;

  @override
  List<Object?> get props => [id, label, icon, type, route, actionKey, children];
}
