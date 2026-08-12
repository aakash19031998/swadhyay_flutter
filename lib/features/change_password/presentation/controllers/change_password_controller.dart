import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_pin_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/change_password_usecase.dart';

/// Weak/repeated/sequential 4-digit PINs the strength meter flags —
/// mirrors the reference Change PIN screen's rule set.
const List<String> _weakPins = [
  '1234', '4321', '0000', '1111', '2222', '3333',
  '4444', '5555', '6666', '7777', '8888', '9999',
];

enum PinStrength { empty, weak, moderate, strong }

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

  final RxBool hideCurrentPassword = true.obs;
  final RxBool hideNewPassword = true.obs;
  final RxBool hideConfirmPassword = true.obs;

  final Rx<PinStrength> newPasswordStrength = PinStrength.empty.obs;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  void toggleCurrentPasswordVisibility() => hideCurrentPassword.value = !hideCurrentPassword.value;

  void toggleNewPasswordVisibility() => hideNewPassword.value = !hideNewPassword.value;

  void toggleConfirmPasswordVisibility() => hideConfirmPassword.value = !hideConfirmPassword.value;

  void onCurrentPasswordChanged(String value) {
    _currentPassword = value;
    if (currentPasswordError.value != null) currentPasswordError.value = null;
  }

  void onNewPasswordChanged(String value) {
    _newPassword = value;
    if (newPasswordError.value != null) newPasswordError.value = null;
    newPasswordStrength.value = _evaluateStrength(value);
  }

  void onConfirmPasswordChanged(String value) {
    _confirmPassword = value;
    if (confirmPasswordError.value != null) confirmPasswordError.value = null;
  }

  PinStrength _evaluateStrength(String pin) {
    if (pin.length < AppDimensions.pinLength) return PinStrength.empty;
    if (_weakPins.contains(pin)) return PinStrength.weak;
    if (pin[0] == pin[1] && pin[2] == pin[3]) return PinStrength.moderate;
    return PinStrength.strong;
  }

  /// UI-ready projection of [newPasswordStrength] so the view stays a pure
  /// template — no color/copy decisions there.
  ({double progress, String label, Color color}) get newPasswordStrengthMeta {
    switch (newPasswordStrength.value) {
      case PinStrength.empty:
        return (progress: 0.0, label: AppStrings.pinStrengthEmpty, color: AppColors.textSecondary);
      case PinStrength.weak:
        return (progress: 0.33, label: AppStrings.pinStrengthWeak, color: AppColors.error);
      case PinStrength.moderate:
        return (progress: 0.66, label: AppStrings.pinStrengthModerate, color: AppColors.warning);
      case PinStrength.strong:
        return (progress: 1.0, label: AppStrings.pinStrengthStrong, color: AppColors.success);
    }
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
      (failure) => AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: failure.message,
        isSuccess: false,
      ),
      (_) {
        AppSnackbar.show(
          title: AppStrings.changePassword,
          message: AppStrings.passwordUpdated,
          isSuccess: true,
        );
        currentPasswordFieldController.clear();
        newPasswordFieldController.clear();
        confirmPasswordFieldController.clear();
        newPasswordStrength.value = PinStrength.empty;
        Get.back<void>();
      },
    );
  }
}
