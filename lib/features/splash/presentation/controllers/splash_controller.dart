import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';

/// Drives the splash screen's single responsibility: stay on screen for
/// exactly 2 seconds, then route to Login or Home depending on whether a
/// session already exists.
class SplashController extends GetxController {
  SplashController(this._localStorageService);

  static const Duration _splashDuration = Duration(seconds: 2);

  final LocalStorageService _localStorageService;

  Timer? _navigationTimer;

  @override
  void onInit() {
    super.onInit();
    _navigationTimer = Timer(_splashDuration, _navigateNext);
  }

  void _navigateNext() {
    final String destination = _localStorageService.isLoggedIn ? AppRoutes.home : AppRoutes.login;
    Get.offAllNamed(destination);
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }
}
