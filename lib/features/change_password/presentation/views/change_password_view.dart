import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: AppStrings.changePassword, showNotification: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Extra bottom room equal to the keyboard's own height: without
            // it, the scroll range can be too short to lift the last PIN
            // section (Confirm New Password) fully above the keyboard.
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              AppDimensions.spacingMd + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
              child: AppCard(
                padding: const EdgeInsets.all(AppDimensions.spacingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    const SizedBox(height: AppDimensions.spacingXl),
                    _PinSection(
                      label: AppStrings.currentPassword,
                      fieldController: controller.currentPasswordFieldController,
                      onChanged: controller.onCurrentPasswordChanged,
                      errorText: controller.currentPasswordError,
                      hidden: controller.hideCurrentPassword,
                      onToggleVisibility: controller.toggleCurrentPasswordVisibility,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _PinSection(
                      label: AppStrings.newPassword,
                      fieldController: controller.newPasswordFieldController,
                      onChanged: controller.onNewPasswordChanged,
                      errorText: controller.newPasswordError,
                      hidden: controller.hideNewPassword,
                      onToggleVisibility: controller.toggleNewPasswordVisibility,
                      strengthBuilder: () => controller.newPasswordStrengthMeta,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _PinSection(
                      label: AppStrings.confirmNewPassword,
                      fieldController: controller.confirmPasswordFieldController,
                      onChanged: controller.onConfirmPasswordChanged,
                      onCompleted: (_) => controller.submit(),
                      errorText: controller.confirmPasswordError,
                      hidden: controller.hideConfirmPassword,
                      onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),
                    Obx(
                      () => AppButton(
                        label: AppStrings.updatePassword,
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

/// Icon badge + title + subtitle identity block at the top of the card.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: AppDimensions.avatarSm + AppDimensions.spacingXs,
          height: AppDimensions.avatarSm + AppDimensions.spacingXs,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: const Icon(Icons.key_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.changePassword,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppDimensions.spacingXxs),
              Text(
                AppStrings.changePasswordSubtitle,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One labeled 4-digit PIN block: uppercase title, a Show/Hide toggle, the
/// digit boxes, and — for the new-password field only — a strength meter.
class _PinSection extends StatelessWidget {
  const _PinSection({
    required this.label,
    required this.fieldController,
    required this.onChanged,
    required this.errorText,
    required this.hidden,
    required this.onToggleVisibility,
    this.onCompleted,
    this.strengthBuilder,
  });

  final String label;
  final AppPinFieldController fieldController;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final RxnString errorText;
  final RxBool hidden;
  final VoidCallback onToggleVisibility;
  final ({double progress, String label, Color color}) Function()? strengthBuilder;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            GestureDetector(
              onTap: onToggleVisibility,
              child: Obx(
                () => Text(
                  hidden.value ? AppStrings.show : AppStrings.hide,
                  style: textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Obx(
          () => AppPinField(
            controller: fieldController,
            obscureText: hidden.value,
            onChanged: onChanged,
            onCompleted: onCompleted,
            errorText: errorText.value,
            boxSize: AppDimensions.changePinBoxSize,
            boxRadius: AppDimensions.radiusLg,
            fillColor: AppColors.surfaceVariant,
          ),
        ),
        if (strengthBuilder != null) ...[
          const SizedBox(height: AppDimensions.spacingSm),
          Obx(() {
            final ({double progress, String label, Color color}) meta = strengthBuilder!();
            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    child: LinearProgressIndicator(
                      value: meta.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(meta.color),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  meta.label,
                  style: textTheme.labelSmall?.copyWith(color: meta.color, fontWeight: FontWeight.w700),
                ),
              ],
            );
          }),
        ],
      ],
    );
  }
}
