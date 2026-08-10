import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/pause_reason_entity.dart';
import '../../domain/usecases/get_pause_reasons_usecase.dart';

/// Asks for a reason before a running bag's timer is paused. Structured
/// like `LogoutDialog`/`SubmitConfirmationDialog` (icon badge + title +
/// Cancel/Submit actions) but swaps the static message for a required
/// reason picker, populated live from `PauseReasonMaster` (see
/// `PauseReasonDependencies` — registered by both the Bag List and Bag
/// Detail bindings before this dialog can ever be opened). Returns the
/// selected [PauseReasonEntity] (so callers have both `reasonId` — needed
/// for `BagTimeTracking`'s `pauseReasonId` — and `reasonDesc`) on Submit,
/// or null on Cancel.
///
/// The picker is a scrollable list of selectable tiles (not the shared
/// `AppDropdown` menu used elsewhere in the app) — a dropdown menu reading
/// 13 live reasons, some of them long ("Machine Breakdown / Tool Issue"),
/// gets cramped; a tile list reads every option clearly and shows the
/// current selection at a glance.
class PauseReasonDialog extends StatefulWidget {
  const PauseReasonDialog({super.key});

  static Future<PauseReasonEntity?> show() =>
      Get.dialog<PauseReasonEntity>(const PauseReasonDialog());

  @override
  State<PauseReasonDialog> createState() => _PauseReasonDialogState();
}

class _PauseReasonDialogState extends State<PauseReasonDialog> {
  PauseReasonEntity? _selectedReason;
  bool _showValidationError = false;
  late Future<List<PauseReasonEntity>> _reasonsFuture;

  @override
  void initState() {
    super.initState();
    _reasonsFuture = _loadReasons();
  }

  Future<List<PauseReasonEntity>> _loadReasons() async {
    final result = await Get.find<GetPauseReasonsUseCase>()();
    return result.fold((failure) => throw failure, (reasons) => reasons);
  }

  void _retry() => setState(() => _reasonsFuture = _loadReasons());

  void _selectReason(PauseReasonEntity reason) {
    setState(() {
      _selectedReason = reason;
      _showValidationError = false;
    });
  }

  void _submit() {
    final PauseReasonEntity? selected = _selectedReason;
    if (selected == null) {
      setState(() => _showValidationError = true);
      return;
    }
    Get.back(result: selected);
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
              FutureBuilder<List<PauseReasonEntity>>(
                future: _reasonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        Text(
                          AppStrings.somethingWentWrong,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        AppButton(
                          label: AppStrings.retry,
                          fullWidth: false,
                          onPressed: _retry,
                        ),
                      ],
                    );
                  }

                  final List<PauseReasonEntity> reasons = snapshot.data ?? const [];
                  return _ReasonPicker(
                    reasons: reasons,
                    selected: _selectedReason,
                    onSelected: _selectReason,
                    showError: _showValidationError,
                  );
                },
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
    );
  }
}

/// Scrollable list of selectable reason tiles, bounded so a long reason
/// list never pushes the dialog's action buttons off-screen.
class _ReasonPicker extends StatelessWidget {
  const _ReasonPicker({
    required this.reasons,
    required this.selected,
    required this.onSelected,
    required this.showError,
  });

  final List<PauseReasonEntity> reasons;
  final PauseReasonEntity? selected;
  final ValueChanged<PauseReasonEntity> onSelected;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            border: Border.all(color: showError ? AppColors.error : AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: reasons.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final PauseReasonEntity reason = reasons[index];
              return _ReasonTile(
                label: reason.reasonDesc,
                selected: reason.reasonId == selected?.reasonId,
                onTap: () => onSelected(reason),
              );
            },
          ),
        ),
        if (showError) ...[
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            AppStrings.pauseReasonRequired,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textHint,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
