import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_card.dart';
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  children: [
                    _MetaPillsRow(controller: controller),
                    const SizedBox(height: AppDimensions.spacingMd),
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

/// Bag No. / Design No. / OrderNo as individual accent-striped cards
/// instead of a flat info strip — laid out side by side on tablet width,
/// stacked on phone width.
class _MetaPillsRow extends StatelessWidget {
  const _MetaPillsRow({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

        final List<Widget> pills = [
          _MetaPill(
            icon: Icons.qr_code_2_rounded,
            color: AppColors.primary,
            label: AppStrings.bagNoShort,
            value: controller.bag.bagNo,
          ),
          _MetaPill(
            icon: Icons.design_services_outlined,
            color: AppColors.info,
            label: AppStrings.designNoLabel,
            value: controller.bag.designNo,
          ),
          _MetaPill(
            icon: Icons.receipt_long_outlined,
            color: AppColors.success,
            label: AppStrings.orderNo,
            value: controller.bag.locationCode,
          ),
        ];

        if (!isTablet) {
          return Column(
            children: [
              for (final pill in pills) ...[
                pill,
                if (pill != pills.last) const SizedBox(height: AppDimensions.spacingSm),
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < pills.length; i++) ...[
                if (i > 0) const SizedBox(width: AppDimensions.spacingSm),
                Expanded(child: pills[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.color, required this.label, required this.value});

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatarSm,
            height: AppDimensions.avatarSm,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.onPrimary, size: AppDimensions.iconMd),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkFormCard extends StatelessWidget {
  const _WorkFormCard({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.addNewWorkEntry,
      icon: Icons.edit_note_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obx nests *inside* LayoutBuilder deliberately: LayoutBuilder's
          // `builder` only runs at layout time, after the surrounding
          // build() has already finished — an Obx wrapped around the
          // LayoutBuilder instead would never see the `.value` reads
          // happening inside it, and GetX throws "improper use of GetX"
          // the moment those values change with nothing subscribed.
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= AppDimensions.breakpointPhone;

              return Obx(() {
                final Widget workTypeField = AppDropdown<String>(
                  label: AppStrings.workType,
                  icon: Icons.category_outlined,
                  items: BagCompletionController.workTypeOptions,
                  itemLabel: (item) => item,
                  value: controller.workType.value,
                  onChanged: controller.onWorkTypeChanged,
                );
                final Widget workField = AppDropdown<String>(
                  label: AppStrings.work,
                  icon: Icons.construction_outlined,
                  items: BagCompletionController.workOptions,
                  itemLabel: (item) => item,
                  value: controller.work.value,
                  onChanged: controller.onWorkChanged,
                );

                if (!isWide) {
                  return Column(
                    children: [
                      workTypeField,
                      const SizedBox(height: AppDimensions.spacingMd),
                      workField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: workTypeField),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(child: workField),
                  ],
                );
              });
            },
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= AppDimensions.breakpointPhone;

              return Obx(() {
                final Widget pieceField = AppTextField(
                  label: AppStrings.pieceStone,
                  keyboardType: TextInputType.number,
                  onChanged: controller.onPieceChanged,
                );
                final Widget addButton = AppButton(
                  label: AppStrings.add,
                  icon: Icons.add_rounded,
                  fullWidth: !isWide,
                  onPressed: controller.canAdd ? controller.addEntry : null,
                );

                if (!isWide) {
                  return Column(
                    children: [
                      pieceField,
                      const SizedBox(height: AppDimensions.spacingMd),
                      addButton,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: pieceField),
                    const SizedBox(width: AppDimensions.spacingMd),
                    SizedBox(width: 140, child: addButton),
                  ],
                );
              });
            },
          ),
        ],
      ),
    );
  }
}

/// Header + rows inside one bordered, rounded box — a real table look
/// instead of a separate dark header pill floating above plain rows.
class _TableContainer extends StatelessWidget {
  const _TableContainer({required this.headers, required this.rows});

  final List<String> headers;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          children: [
            ColoredBox(
              color: AppColors.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                child: Row(
                  children: [
                    for (final label in headers)
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.4,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            for (final row in rows)
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: row,
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
    return SectionCard(
      title: AppStrings.pendingSettings,
      icon: Icons.hourglass_empty_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TableContainer(
            headers: [AppStrings.setting, AppStrings.pieces, AppStrings.select],
            rows: [],
          ),
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
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: AppDimensions.iconSm, color: AppColors.warning),
                const SizedBox(width: AppDimensions.spacingXs),
                Flexible(
                  child: Text(
                    AppStrings.pleaseSelectPndPredData,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
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
    return SectionCard(
      title: AppStrings.recordedSettings,
      icon: Icons.fact_check_outlined,
      child: Obx(() {
        return _TableContainer(
          headers: const [AppStrings.setting, AppStrings.pieces, ''],
          rows: [
            for (int i = 0; i < controller.recordedSettings.length; i++)
              _RecordedSettingRow(
                entry: controller.recordedSettings[i],
                onRemove: () => controller.removeEntry(i),
              ),
          ],
        );
      }),
    );
  }
}

class _RecordedSettingRow extends StatelessWidget {
  const _RecordedSettingRow({required this.entry, required this.onRemove});

  final SettingEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(entry.setting, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(child: Text('${entry.pieces}', style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _DangerIconButton(icon: Icons.delete_outline_rounded, onTap: onRemove),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerIconButton extends StatelessWidget {
  const _DangerIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.errorContainer,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: AppDimensions.iconSm, color: AppColors.error),
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
