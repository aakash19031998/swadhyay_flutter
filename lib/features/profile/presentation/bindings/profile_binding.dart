import 'package:get/get.dart';

import '../../../authentication/domain/entities/employee_entity.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final EmployeeEntity employee = Get.arguments as EmployeeEntity;
    Get.put(ProfileController(employee));
  }
}
