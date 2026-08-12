import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_strings.dart';
import '../widgets/app_snackbar.dart';
import 'network_info.dart';

/// Single reusable connectivity gate for the whole app.
///
/// [ApiClient] checks [NetworkInfo] directly and throws [NetworkException]
/// so an offline API call surfaces exactly once, through the existing
/// Failure/snackbar pipeline every controller already has. Everything that
/// wants to short-circuit *before* attempting a network action — a button
/// tap, a search keystroke — calls [ensureConnected] here instead, so no
/// screen reimplements its own "are we online" check or offline messaging.
class ConnectivityChecker {
  ConnectivityChecker(this._networkInfo);

  final NetworkInfo _networkInfo;

  /// Returns `true` when online. When offline, shows a themed "no internet"
  /// snackbar and returns `false` so the caller can bail out before doing
  /// any work.
  Future<bool> ensureConnected() async {
    final bool isConnected = await _networkInfo.isConnected;
    if (!isConnected) _showOfflineSnackbar();
    return isConnected;
  }

  void _showOfflineSnackbar() {
    if (Get.isSnackbarOpen) return;
    AppSnackbar.show(
      title: AppStrings.alertWarning,
      message: AppStrings.noInternetConnection,
      isSuccess: false,
      icon: Icons.wifi_off_rounded,
    );
  }
}
