import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../network/api_client.dart';
import '../network/connectivity_checker.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/network_info.dart';
import '../services/app_update_controller.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

/// Registers app-wide singletons that every feature binding may depend on:
/// storage, connectivity, and the shared [ApiClient].
///
/// Feature-specific dependencies (repositories, use cases, controllers)
/// belong in that feature's own `Binding` — this is the only binding wired
/// via `GetMaterialApp.initialBinding`.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FlutterSecureStorage>(const FlutterSecureStorage(), permanent: true);
    Get.put<GetStorage>(GetStorage(), permanent: true);
    Get.put<Connectivity>(Connectivity(), permanent: true);

    Get.put<SecureStorageService>(
      SecureStorageService(Get.find<FlutterSecureStorage>()),
      permanent: true,
    );
    Get.put<LocalStorageService>(
      LocalStorageService(Get.find<GetStorage>()),
      permanent: true,
    );
    Get.put<NetworkInfo>(
      NetworkInfoImpl(Get.find<Connectivity>()),
      permanent: true,
    );
    Get.put<ConnectivityChecker>(
      ConnectivityChecker(Get.find<NetworkInfo>()),
      permanent: true,
    );

    final AuthInterceptor authInterceptor = AuthInterceptor(
      Get.find<SecureStorageService>(),
      onUnauthorized: () async {
        await Get.find<SecureStorageService>().clear();
        await Get.find<LocalStorageService>().setLoggedIn(false);
      },
    );
    Get.put<ApiClient>(
      ApiClient(ApiClient.buildDio(authInterceptor: authInterceptor), Get.find<NetworkInfo>()),
      permanent: true,
    );

    Get.put<AppUpdateController>(AppUpdateController(), permanent: true);
  }
}
