import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Owns the force-update dialog's download-and-install flow end to end.
/// Registered once as a permanent singleton (see [InitialBinding]) so
/// [ForceUpdateGuard] — triggered from [ApiClient], far below any screen —
/// can drive it regardless of which screen/controller made the API call
/// that surfaced the update.
class AppUpdateController extends GetxController {
  final RxBool isDownloading = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxnString error = RxnString();

  Future<void> downloadAndInstall(String updateUrl) async {
    if (isDownloading.value) return;

    error.value = null;
    isDownloading.value = true;
    progress.value = 0;

    try {
      // Android 8+ requires this permission before a normal (non-store)
      // app can trigger the system package installer.
      final PermissionStatus status = await Permission.requestInstallPackages.request();
      if (!status.isGranted) {
        error.value = 'Please allow "Install unknown apps" for this app, then try again.';
        return;
      }

      final Directory dir = await getApplicationDocumentsDirectory();
      final String savePath = '${dir.path}/swadhyay_update.apk';

      await Dio().download(
        updateUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) progress.value = received / total;
        },
      );

      // Handed to the OS's own package installer here — this app has no
      // control past this point. Updating over the currently installed
      // app (same package + signing key) preserves all stored data and
      // the active login session automatically; that's standard Android
      // update behavior, not something this flow has to manage itself.
      await OpenFilex.open(savePath);
    } catch (_) {
      error.value = 'Unable to download the update. Please check your connection and try again.';
    } finally {
      isDownloading.value = false;
    }
  }
}
