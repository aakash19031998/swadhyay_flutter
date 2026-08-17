import 'package:get/get.dart';

import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/change_password_usecase.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    Get.lazyPut<ChangePasswordUseCase>(() => ChangePasswordUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(
        Get.find<ChangePasswordUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
      ),
    );
  }
}
