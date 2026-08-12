import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_modern_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/flex_table.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/comp_pred_entity.dart';
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
              child: Obx(() {
                if (controller.isLoading.value) return const HkLoaderCard();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: Column(
                    children: [
                      _MetaPillsRow(controller: controller),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _WorkFormCard(controller: controller),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _PendingWorkCard(controller: controller),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _CompletedWorkCard(controller: controller),
                    ],
                  ),
                );
              }),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatarSm,
            height: AppDimensions.avatarSm,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, Color.lerp(color, Colors.black, 0.22)!],
              ),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))],
            ),
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
      accentColor: AppColors.primary,
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
                final bool enabled = controller.addDummyWork.value;
                // Read as a plain list *here*, inside the Obx builder —
                // `_ModernDropdown` iterates `options` one level down, in
                // its own build(), which Obx can't see into: passing the
                // RxList reference straight through would leave this Obx
                // subscribed to nothing, so a later `workOptions.value = [
                // ...]` (once `SubWorkType` resolves) would never trigger a
                // rebuild and the dropdown would stay stuck on whatever it
                // had (often empty) the moment Work Type was picked.
                final List<String> workTypeOpts = controller.workTypeOptions.toList();
                final List<String> workOpts = controller.workOptions.toList();

                final Widget workTypeField = AppModernDropdown<String>(
                  label: AppStrings.workType,
                  icon: Icons.category_outlined,
                  items: workTypeOpts,
                  itemLabel: (item) => item,
                  value: controller.workType.value,
                  onChanged: enabled ? controller.onWorkTypeChanged : null,
                );
                final Widget workField = AppModernDropdown<String>(
                  label: AppStrings.work,
                  icon: Icons.construction_outlined,
                  items: workOpts,
                  itemLabel: (item) => item,
                  value: controller.work.value,
                  onChanged: enabled ? controller.onWorkChanged : null,
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
                  controller: controller.pieceController,
                  keyboardType: TextInputType.number,
                  enabled: controller.addDummyWork.value,
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

/// The "Pending Work" card — bound to `BagDoneDetail`'s `PndPred` array,
/// with the Add/Delete mechanism operating on the same
/// `controller.recordedSettings` list. Table styled with the same
/// [FlexTable] used by the Bag Detail screen's Diamond Details/Bag RM
/// Summary tables, so every data table in the app reads the same way.
class _PendingWorkCard extends StatelessWidget {
  const _PendingWorkCard({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.pendingWork,
      icon: Icons.pending_actions_rounded,
      accentColor: AppColors.warning,
      padding: EdgeInsets.zero,
      child: Obx(() {
        final List<SettingEntry> entries = controller.recordedSettings;

        return FlexTable(
          isEmpty: entries.isEmpty,
          columns: const [
            FlexColumn(label: AppStrings.transactionId, flex: 1),
            FlexColumn(label: AppStrings.setId, flex: 1),
            FlexColumn(label: AppStrings.setting, flex: 1),
            FlexColumn(label: AppStrings.pieces, flex: 1),
          ],
          rows: [
            for (final entry in entries)
              [
                (entry.trnId?.isNotEmpty ?? false) ? entry.trnId! : '—',
                entry.setId?.toString() ?? '—',
                entry.setting,
                '${entry.pieces}',
              ],
          ],
          rowTrailing: (rowIndex) => _DangerIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: () => controller.removeEntry(rowIndex),
          ),
        );
      }),
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
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: AppDimensions.iconSm, color: AppColors.error),
        ),
      ),
    );
  }
}

/// The "Completed Work" card — bound to `BagDoneDetail`'s `CompPred` array
/// (`Prediction` -> Setting, `Stone` -> Pieces/Stones); the same [FlexTable]
/// style as the Bag Detail screen's tables, including its own built-in
/// empty state.
class _CompletedWorkCard extends StatelessWidget {
  const _CompletedWorkCard({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.completedWork,
      icon: Icons.task_alt_rounded,
      accentColor: AppColors.success,
      padding: EdgeInsets.zero,
      child: Obx(() {
        final List<CompPredEntity> entries = controller.completedWork;

        return FlexTable(
          isEmpty: entries.isEmpty,
          columns: const [
            FlexColumn(label: AppStrings.setting, flex: 1),
            FlexColumn(label: AppStrings.piecesStones, flex: 1),
          ],
          rows: [
            for (final entry in entries) [entry.prediction, '${entry.stone}'],
          ],
        );
      }),
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
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
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
              child: AppButton(
                label: AppStrings.submit,
                icon: Icons.check_circle_outline_rounded,
                onPressed: controller.submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
