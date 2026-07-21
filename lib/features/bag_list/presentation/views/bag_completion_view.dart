import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/bag_completion_controller.dart';

/// The "Done" completion form opened from both the bag list and the bag
/// detail screen: record settings/pieces worked on, then submit to close
/// out the bag.
class BagCompletionView extends GetView<BagCompletionController> {
  const BagCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(controller: controller),
            _BagInfoStrip(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  children: [
                    _WorkFormCard(controller: controller),
                    const SizedBox(height: AppDimensions.spacingMd),
                    const _PendingSettingsCard(),
                    const SizedBox(height: AppDimensions.spacingMd),
                    _RecordedSettingsCard(controller: controller),
                  ],
                ),
              ),
            ),
            _BottomActions(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXs,
            vertical: AppDimensions.spacingXs,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
                onPressed: controller.cancel,
              ),
              Text(
                AppStrings.firstReceived,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BagInfoStrip extends StatelessWidget {
  const _BagInfoStrip({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            Expanded(child: _InfoField(label: AppStrings.bagNoShort, value: controller.bag.bagNo)),
            Expanded(child: _InfoField(label: AppStrings.designNoLabel, value: controller.bag.designNo)),
            Expanded(child: _InfoField(label: AppStrings.orderNo, value: controller.bag.locationCode)),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.primary)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _WorkFormCard extends StatelessWidget {
  const _WorkFormCard({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    label: AppStrings.workType,
                    items: BagCompletionController.workTypeOptions,
                    itemLabel: (item) => item,
                    value: controller.workType.value,
                    onChanged: controller.onWorkTypeChanged,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: AppDropdown<String>(
                    label: AppStrings.work,
                    items: BagCompletionController.workOptions,
                    itemLabel: (item) => item,
                    value: controller.work.value,
                    onChanged: controller.onWorkChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppTextField(
                    label: AppStrings.pieceStone,
                    keyboardType: TextInputType.number,
                    onChanged: controller.onPieceChanged,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                AppButton(
                  label: AppStrings.add,
                  icon: Icons.add_rounded,
                  fullWidth: false,
                  onPressed: controller.canAdd ? controller.addEntry : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingSettingsCard extends StatelessWidget {
  const _PendingSettingsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.pendingSettings,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _TableHeaderRow(labels: [AppStrings.setting, AppStrings.pieces, AppStrings.select]),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: AppDimensions.iconSm, color: AppColors.warning),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  AppStrings.pleaseSelectPndPredData,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordedSettingsCard extends StatelessWidget {
  const _RecordedSettingsCard({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.recordedSettings,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _TableHeaderRow(labels: [AppStrings.setting, AppStrings.pieces, '']),
          Obx(() {
            if (controller.recordedSettings.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
                child: Center(
                  child: Text(
                    AppStrings.noDataFound,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (int i = 0; i < controller.recordedSettings.length; i++)
                  _RecordedSettingRow(
                    entry: controller.recordedSettings[i],
                    isLast: i == controller.recordedSettings.length - 1,
                    onRemove: () => controller.removeEntry(i),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _RecordedSettingRow extends StatelessWidget {
  const _RecordedSettingRow({required this.entry, required this.isLast, required this.onRemove});

  final SettingEntry entry;
  final bool isLast;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
        child: Row(
          children: [
            Expanded(child: Text(entry.setting, style: Theme.of(context).textTheme.bodyMedium)),
            Expanded(child: Text('${entry.pieces}', style: Theme.of(context).textTheme.bodyMedium)),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: AppDimensions.iconSm),
                  color: AppColors.error,
                  onPressed: onRemove,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: AppStrings.cancel,
                variant: AppButtonVariant.outlined,
                onPressed: controller.cancel,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: AppButton(label: AppStrings.submit, onPressed: controller.submit),
            ),
          ],
        ),
      ),
    );
  }
}
