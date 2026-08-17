import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/datasources/auth_data_source.dart';
import '../data/datasources/auth_remote_data_source_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

/// Registers [AuthRepository] as an app-lifetime singleton.
///
/// Authentication is a cross-cutting concern needed by Login, Home
/// (logout) and Change Password — whichever of those screens is entered
/// first performs the registration; the others simply find the existing
/// instance. Always wired to the live backend — no mock option for any of
/// Login, Logout, or Change Password.
class AuthDependencies {
  const AuthDependencies._();

  static void ensureRegistered() {
    if (Get.isRegistered<AuthRepository>()) return;

    Get.put<AuthDataSource>(
      AuthRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        Get.find<AuthDataSource>(),
        Get.find<SecureStorageService>(),
        Get.find<LocalStorageService>(),
      ),
      permanent: true,
    );
  }
}
