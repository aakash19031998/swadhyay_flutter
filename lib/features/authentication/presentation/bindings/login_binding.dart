import 'package:get/get.dart';

import '../../di/auth_dependencies.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<LoginController>(() => LoginController(Get.find<LoginUseCase>()));
  }
}
