import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pin_field.dart';
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _PinLabel(AppStrings.currentPassword),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Obx(
                      () => AppPinField(
                        controller: controller.currentPasswordFieldController,
                        onChanged: controller.onCurrentPasswordChanged,
                        errorText: controller.currentPasswordError.value,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _PinLabel(AppStrings.newPassword),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Obx(
                      () => AppPinField(
                        controller: controller.newPasswordFieldController,
                        onChanged: controller.onNewPasswordChanged,
                        errorText: controller.newPasswordError.value,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _PinLabel(AppStrings.confirmNewPassword),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Obx(
                      () => AppPinField(
                        controller: controller.confirmPasswordFieldController,
                        onChanged: controller.onConfirmPasswordChanged,
                        onCompleted: (_) => controller.submit(),
                        errorText: controller.confirmPasswordError.value,
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
    );
  }
}

class _PinLabel extends StatelessWidget {
  const _PinLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
