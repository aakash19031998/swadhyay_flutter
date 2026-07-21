import 'package:get/get.dart';

import '../../../authentication/domain/entities/employee_entity.dart';

/// Holds the [EmployeeEntity] passed in via `Get.arguments` when the drawer
/// header is tapped — this screen is a pure read-only view, so it has no
/// data source of its own.
class ProfileController extends GetxController {
  ProfileController(this.employee);

  final EmployeeEntity employee;
}
