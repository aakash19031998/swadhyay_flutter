import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Confirmation shown before the "Done" completion form actually saves —
/// same branded-dialog language as [LogoutDialog] (icon badge, title,
/// message, Cancel + primary action) so this high-visibility moment gets
/// the same considered design instead of a bare system alert.
class SubmitConfirmationDialog extends StatelessWidget {
  const SubmitConfirmationDialog({super.key});

  static Future<bool> show() async {
    final bool? result = await Get.dialog<bool>(const SubmitConfirmationDialog());
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.dialogMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingLg,
            AppDimensions.spacingXl,
            AppDimensions.spacingLg,
            AppDimensions.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimensions.avatarLg,
                height: AppDimensions.avatarLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successContainer,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.success,
                  size: AppDimensions.iconXl,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                AppStrings.submitConfirmTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                AppStrings.submitConfirmMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: AppStrings.cancel,
                    variant: AppButtonVariant.outlined,
                    fullWidth: false,
                    onPressed: () => Get.back(result: false),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  AppButton(
                    label: AppStrings.submit,
                    icon: Icons.check_rounded,
                    fullWidth: false,
                    onPressed: () => Get.back(result: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
