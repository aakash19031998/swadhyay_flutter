import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../authentication/domain/entities/employee_entity.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../authentication/domain/usecases/logout_usecase.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';
import '../../domain/usecases/get_drawer_menu_usecase.dart';
import '../widgets/logout_dialog.dart';

/// Owns the home shell's state: the signed-in employee (for [ProfileCard]),
/// the drawer menu tree, and the logout flow. Screen-specific state (bag
/// list rows, report filters, etc.) lives in each destination feature's own
/// controller, not here.
class HomeController extends GetxController {
  HomeController(
    this._getCurrentEmployeeUseCase,
    this._getDrawerMenuUseCase,
    this._logoutUseCase,
  );

  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final GetDrawerMenuUseCase _getDrawerMenuUseCase;
  final LogoutUseCase _logoutUseCase;

  final Rxn<EmployeeEntity> employee = Rxn<EmployeeEntity>();
  final RxList<DrawerMenuItemEntity> menuItems = <DrawerMenuItemEntity>[].obs;
  final RxBool isMenuLoading = true.obs;
  final RxBool isLoggingOut = false.obs;

  /// Plain (non-reactive) re-entrancy guard for [loadMenu] — separate from
  /// [isMenuLoading], which starts `true` to show a loader before the very
  /// first fetch has even begun and so can't double as an "already
  /// fetching" check.
  bool _isFetchingMenu = false;

  /// `MenuListNew` never sends a logout entry — it's an app-level action,
  /// not a backend screen — so it's always appended locally.
  static const DrawerMenuItemEntity _logoutMenuItem = DrawerMenuItemEntity(
    id: 'logout',
    label: AppStrings.logout,
    icon: Icons.logout,
    type: DrawerMenuItemType.action,
    actionKey: 'logout',
  );

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadEmployee();
    await loadMenu();
  }

  Future<void> _loadEmployee() async {
    employee.value = await _getCurrentEmployeeUseCase();
  }

  /// Re-fetches `MenuListNew` fresh every time it's called — no local
  /// caching, so [AppDrawer] calls this on every single open (see
  /// `Scaffold.onDrawerChanged` in [HomeView]), not just once at startup.
  ///
  /// Guarded against overlapping calls: the startup load from [_initialize]
  /// and a drawer-open triggered reload can otherwise race if the drawer is
  /// opened right as the screen first appears, firing two concurrent
  /// requests against the same `isMenuLoading`/`menuItems` state.
  ///
  /// Also re-loads [employee] first if it isn't populated yet — a fast
  /// drawer-open can otherwise win that same race and call the API with an
  /// empty `empCd` before [_initialize]'s own load has finished, which the
  /// backend rejects outright (500).
  Future<void> loadMenu() async {
    if (_isFetchingMenu) return;
    _isFetchingMenu = true;
    isMenuLoading.value = true;

    if (employee.value == null) await _loadEmployee();

    final result = await _getDrawerMenuUseCase(employee.value?.empCode ?? '');
    result.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (items) => menuItems.assignAll([...items, _logoutMenuItem]),
    );
    isMenuLoading.value = false;
    _isFetchingMenu = false;
  }

  void onProfileTap() {
    final EmployeeEntity? current = employee.value;
    if (current == null) return;

    Get.back<void>(); // close the drawer first.
    Get.toNamed(AppRoutes.profile, arguments: current);
  }

  void onMenuItemTap(DrawerMenuItemEntity item) {
    Get.back<void>(); // close the drawer first.

    if (item.type == DrawerMenuItemType.action && item.actionKey == 'logout') {
      logout();
      return;
    }
    if (item.route != null) {
      Get.toNamed(item.route!);
    }
  }

  Future<void> logout() async {
    final bool confirmed = await LogoutDialog.show();
    if (!confirmed) return;

    isLoggingOut.value = true;
    final result = await _logoutUseCase();
    isLoggingOut.value = false;

    result.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (_) => Get.offAllNamed(AppRoutes.login),
    );
  }
}
