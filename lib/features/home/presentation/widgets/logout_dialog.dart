import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Branded logout confirmation — HK logo badge, a warmer message than a
/// bare "Are you sure?", and Cancel/Logout actions. Shown in place of the
/// generic [AppDialog.confirm] so this specific, high-visibility moment
/// gets its own considered design.
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static Future<bool> show() async {
    final bool? result = await Get.dialog<bool>(const LogoutDialog());
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
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SvgPicture.asset(AppAssets.logoHk, fit: BoxFit.contain),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                AppStrings.logoutConfirmTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                AppStrings.logoutConfirmMessage,
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
                    label: AppStrings.logout,
                    icon: Icons.logout_rounded,
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
