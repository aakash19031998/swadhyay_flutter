import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_pin_field.dart';
import '../../domain/usecases/login_usecase.dart';

/// Receives UI events from [LoginView], delegates authentication to
/// [LoginUseCase], and exposes reactive state for the view to render — no
/// business logic (validation of *what makes credentials valid* lives in
/// the use case/repository) beyond wiring form state.
class LoginController extends GetxController {
  LoginController(this._loginUseCase);

  final LoginUseCase _loginUseCase;

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

  Future<void> login() async {
    final bool isFormValid = formKey.currentState?.validate() ?? false;
    if (_pin.length != AppDimensions.pinLength) {
      pinErrorText.value = AppStrings.pinRequired;
    }
    if (!isFormValid || _pin.length != AppDimensions.pinLength) return;

    isLoading.value = true;
    final result = await _loginUseCase(
      LoginParams(employeeNumber: employeeNumberController.text.trim(), pin: _pin),
    );
    isLoading.value = false;

    result.fold(
      (failure) {
        pinFieldController.clear();
        pinErrorText.value = failure.message;
        _showResultSnackbar(
          title: AppStrings.somethingWentWrong,
          message: failure.message,
          isSuccess: false,
        );
      },
      (success) {
        _showResultSnackbar(
          title: AppStrings.loginSuccessTitle,
          message: success.message,
          isSuccess: true,
        );
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }

  /// Solid, high-contrast success/failure snackbar — the GetX default
  /// (dark-grey background, no icon) reads poorly against this app's
  /// gradient login screen, so title/message color and background are set
  /// explicitly against the app's semantic success/error tokens.
  void _showResultSnackbar({required String title, required String message, required bool isSuccess}) {
    final Color color = isSuccess ? AppColors.success : AppColors.error;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: AppColors.onPrimary,
      icon: Icon(
        isSuccess ? Icons.check_circle_outline : Icons.error_outline,
        color: AppColors.onPrimary,
      ),
      shouldIconPulse: false,
      margin: const EdgeInsets.all(AppDimensions.spacingMd),
      borderRadius: AppDimensions.radiusMd,
      duration: Duration(seconds: isSuccess ? 2 : 3),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  @override
  void onClose() {
    employeeNumberController.dispose();
    super.onClose();
  }
}
