import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';

/// Asks for a reason before a running bag's timer is paused. Structured
/// like `LogoutDialog`/`SubmitConfirmationDialog` (icon badge + title +
/// Cancel/Submit actions) but swaps the static message for a required
/// reason dropdown. Returns the selected reason on Submit, or null on
/// Cancel.
class PauseReasonDialog extends StatefulWidget {
  const PauseReasonDialog({super.key});

  static const List<String> reasons = [
    'Break',
    'Machine Issue',
    'Material Shortage',
    'Awaiting Instruction',
    'Other',
  ];

  static Future<String?> show() => Get.dialog<String>(const PauseReasonDialog());

  @override
  State<PauseReasonDialog> createState() => _PauseReasonDialogState();
}

class _PauseReasonDialogState extends State<PauseReasonDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedReason;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.back(result: _selectedReason);
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimensions.avatarLg,
                  height: AppDimensions.avatarLg,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.warningContainer),
                  child: const Icon(
                    Icons.pause_circle_outline_rounded,
                    color: AppColors.warning,
                    size: AppDimensions.iconLg,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  AppStrings.pauseReasonTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  AppStrings.pauseReasonMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                AppDropdown<String>(
                  label: AppStrings.reason,
                  hint: AppStrings.pauseReasonHint,
                  value: _selectedReason,
                  items: PauseReasonDialog.reasons,
                  itemLabel: (item) => item,
                  onChanged: (value) => setState(() => _selectedReason = value),
                  validator: (value) => value == null ? AppStrings.pauseReasonRequired : null,
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: AppStrings.cancel,
                      variant: AppButtonVariant.outlined,
                      fullWidth: false,
                      onPressed: () => Get.back(result: null),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    AppButton(
                      label: AppStrings.submit,
                      icon: Icons.pause_rounded,
                      fullWidth: false,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
