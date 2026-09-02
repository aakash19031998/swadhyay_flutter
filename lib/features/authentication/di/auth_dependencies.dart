import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/datasources/auth_data_source.dart';
import '../data/datasources/auth_remote_data_source_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_current_employee_usecase.dart';

/// Registers [AuthRepository] and [GetCurrentEmployeeUseCase] as
/// app-lifetime singletons.
///
/// Authentication is a cross-cutting concern needed by nearly every
/// feature (to resolve the current employee code) as well as Login, Home
/// (logout) and Change Password — whichever screen is entered first
/// performs the registration; the others simply find the existing
/// instances. Always wired to the live backend — no mock option for any of
/// Login, Logout, or Change Password. [GetCurrentEmployeeUseCase] is a
/// pure, stateless wrapper around [AuthRepository.currentEmployee], so
/// sharing one instance across every feature is inert.
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

    Get.put<GetCurrentEmployeeUseCase>(
      GetCurrentEmployeeUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );
  }
}
