import 'package:get/get.dart';

import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../../authentication/domain/usecases/logout_usecase.dart';
import '../../di/drawer_menu_dependencies.dart';
import '../../domain/repositories/drawer_menu_repository.dart';
import '../../domain/usecases/get_drawer_menu_usecase.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();
    DrawerMenuDependencies.ensureRegistered();

    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<GetDrawerMenuUseCase>(() => GetDrawerMenuUseCase(Get.find<DrawerMenuRepository>()));

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<GetDrawerMenuUseCase>(),
        Get.find<LogoutUseCase>(),
      ),
    );
  }
}
