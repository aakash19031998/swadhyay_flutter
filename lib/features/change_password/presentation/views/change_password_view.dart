import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.changePassword, showNotification: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
              child: AppCard(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(
                        () => AppTextField(
                          label: AppStrings.currentPassword,
                          controller: controller.currentPasswordController,
                          obscureText: !controller.isCurrentPasswordVisible.value,
                          prefixIcon: Icons.lock_outline,
                          textInputAction: TextInputAction.next,
                          validator: (value) => Validators.required(value, message: '${AppStrings.currentPassword} is required'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isCurrentPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => controller.isCurrentPasswordVisible.toggle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      Obx(
                        () => AppTextField(
                          label: AppStrings.newPassword,
                          controller: controller.newPasswordController,
                          obscureText: !controller.isNewPasswordVisible.value,
                          prefixIcon: Icons.lock_reset_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (value) => Validators.required(value, message: '${AppStrings.newPassword} is required'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isNewPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => controller.isNewPasswordVisible.toggle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      Obx(
                        () => AppTextField(
                          label: AppStrings.confirmNewPassword,
                          controller: controller.confirmPasswordController,
                          obscureText: !controller.isConfirmPasswordVisible.value,
                          prefixIcon: Icons.lock_person_outlined,
                          textInputAction: TextInputAction.done,
                          validator: controller.validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => controller.isConfirmPasswordVisible.toggle(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      Obx(
                        () => AppButton(
                          label: AppStrings.save,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
