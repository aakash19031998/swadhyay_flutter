import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../authentication/domain/usecases/change_password_usecase.dart';

/// Change-password form state. The actual authentication rule (what makes
/// a password valid, whether the current password matches) lives in
/// [ChangePasswordUseCase]/`AuthRepository` — this controller only wires
/// form fields to that use case.
class ChangePasswordController extends GetxController {
  ChangePasswordController(this._changePasswordUseCase);

  final ChangePasswordUseCase _changePasswordUseCase;

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordsDoNotMatch;
    if (value != newPasswordController.text) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      ),
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (_) {
        Get.snackbar(AppStrings.changePassword, AppStrings.passwordUpdated);
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Get.back<void>();
      },
    );
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
