import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_pin_field.dart';
import '../../../authentication/domain/usecases/change_password_usecase.dart';

/// Change-password form state. Every field is a 4-digit PIN — same input
/// as the login screen — not a free-text password. The actual
/// authentication rule (whether the current PIN matches) lives in
/// [ChangePasswordUseCase]/`AuthRepository`; this controller only wires the
/// three PIN fields to that use case.
class ChangePasswordController extends GetxController {
  ChangePasswordController(this._changePasswordUseCase);

  final ChangePasswordUseCase _changePasswordUseCase;

  final currentPasswordFieldController = AppPinFieldController();
  final newPasswordFieldController = AppPinFieldController();
  final confirmPasswordFieldController = AppPinFieldController();

  final RxnString currentPasswordError = RxnString();
  final RxnString newPasswordError = RxnString();
  final RxnString confirmPasswordError = RxnString();
  final RxBool isLoading = false.obs;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  void onCurrentPasswordChanged(String value) {
    _currentPassword = value;
    if (currentPasswordError.value != null) currentPasswordError.value = null;
  }

  void onNewPasswordChanged(String value) {
    _newPassword = value;
    if (newPasswordError.value != null) newPasswordError.value = null;
  }

  void onConfirmPasswordChanged(String value) {
    _confirmPassword = value;
    if (confirmPasswordError.value != null) confirmPasswordError.value = null;
  }

  Future<void> submit() async {
    bool isValid = true;

    if (_currentPassword.length != AppDimensions.pinLength) {
      currentPasswordError.value = AppStrings.pinRequired;
      isValid = false;
    }
    if (_newPassword.length != AppDimensions.pinLength) {
      newPasswordError.value = AppStrings.pinRequired;
      isValid = false;
    }
    if (_confirmPassword.length != AppDimensions.pinLength) {
      confirmPasswordError.value = AppStrings.pinRequired;
      isValid = false;
    } else if (_confirmPassword != _newPassword) {
      confirmPasswordError.value = AppStrings.passwordsDoNotMatch;
      isValid = false;
    }

    if (!isValid) return;

    isLoading.value = true;
    final result = await _changePasswordUseCase(
      ChangePasswordParams(currentPassword: _currentPassword, newPassword: _newPassword),
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (_) {
        Get.snackbar(AppStrings.changePassword, AppStrings.passwordUpdated);
        currentPasswordFieldController.clear();
        newPasswordFieldController.clear();
        confirmPasswordFieldController.clear();
        Get.back<void>();
      },
    );
  }
}
