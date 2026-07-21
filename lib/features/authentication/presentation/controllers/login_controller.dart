import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/widgets/app_pin_field.dart';
import '../../data/models/employee_model.dart';
import '../../domain/usecases/login_usecase.dart';

/// Receives UI events from [LoginView], delegates authentication to
/// [LoginUseCase], and exposes reactive state for the view to render — no
/// business logic (validation of *what makes credentials valid* lives in
/// the use case/repository) beyond wiring form state.
class LoginController extends GetxController {
  LoginController(this._loginUseCase, this._localStorageService);

  final LoginUseCase _loginUseCase;
  final LocalStorageService _localStorageService;

  final formKey = GlobalKey<FormState>();
  final employeeNumberController = TextEditingController();
  final pinFieldController = AppPinFieldController();

  final RxBool isLoading = false.obs;
  final RxnString pinErrorText = RxnString();

  String _pin = '';

  void onPinChanged(String value) {
    _pin = value;
    if (pinErrorText.value != null) pinErrorText.value = null;
  }

  // DEMO BYPASS: skips LoginUseCase entirely so any employee number + any
  // 4-digit PIN logs in. Remove this short-circuit and restore the
  // _loginUseCase call below before shipping past the demo.
  static const bool _demoBypassAuth = true;

  Future<void> login() async {
    final bool isFormValid = formKey.currentState?.validate() ?? false;
    if (_pin.length != AppDimensions.pinLength) {
      pinErrorText.value = AppStrings.pinRequired;
    }
    if (!isFormValid || _pin.length != AppDimensions.pinLength) return;

    if (_demoBypassAuth) {
      final EmployeeModel demoEmployee = EmployeeModel(
        empCode: '11111',
        name: 'HK Design',
        punchInAt: DateTime.now(),
        department: 'Filing C',
        contactNumber: '+91 98765 43210',
        alternateContactNumber: '+91 91234 56789',
        address: '123, Diamond Market, Surat, Gujarat',
        workEfficiency: '92%',
      );
      await _localStorageService.saveJson(StorageKeys.loggedInEmployee, demoEmployee.toJson());
      await _localStorageService.setLoggedIn(true);
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    isLoading.value = true;
    final result = await _loginUseCase(
      LoginParams(employeeNumber: employeeNumberController.text.trim(), pin: _pin),
    );
    isLoading.value = false;

    result.fold(
      (failure) {
        pinFieldController.clear();
        pinErrorText.value = failure.message;
        Get.snackbar(
          AppStrings.somethingWentWrong,
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (_) => Get.offAllNamed(AppRoutes.home),
    );
  }

  @override
  void onClose() {
    employeeNumberController.dispose();
    super.onClose();
  }
}
