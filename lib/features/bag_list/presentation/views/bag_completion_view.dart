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
                      _WorkFormCard(controller: controller),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _PendingAndCompletedWorkRow(controller: controller),
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

/// Back button plus Bag No. / Design No. / Order No. — moved here from
/// their own card row in the scrollable body so they're visible without
/// scrolling, same as the rest of the app's top bars.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.onPrimary,
                ),
                onPressed: controller.cancel,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TopBarInfoItem(
                        label: AppStrings.bagNoShort,
                        value: controller.bag.bagNo,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: _TopBarInfoItem(
                        label: AppStrings.designNoLabel,
                        value: controller.bag.designNo,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: _TopBarInfoItem(
                        label: AppStrings.orderNo,
                        value: controller.bag.locationCode,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One compact label/value pair inside [_TopBar] — [label] dimmed against
/// the gradient, [value] full-strength [AppColors.onPrimary], both single
/// line with ellipsis so a long value can't push the row onto a second
/// line or overflow the toolbar.
class _TopBarInfoItem extends StatelessWidget {
  const _TopBarInfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.72),
            letterSpacing: 0.4,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w800,
          ),
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
    return SectionCard(
      title: AppStrings.addNewWorkEntry,
      icon: Icons.edit_note_outlined,
      accentColor: AppColors.primary,
      headerPadding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingXs,
      ),
      titleFontSize: 17,
      iconSize: 17,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
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
              final bool isWide =
                  constraints.maxWidth >= AppDimensions.breakpointPhone;

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
                final List<String> workTypeOpts = controller.workTypeOptions
                    .toList();
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
                final Widget pieceField = AppTextField(
                  label: AppStrings.pieceStone,
                  controller: controller.pieceController,
                  keyboardType: TextInputType.number,
                  enabled: enabled,
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
                      workTypeField,
                      const SizedBox(height: AppDimensions.spacingMd),
                      workField,
                      const SizedBox(height: AppDimensions.spacingMd),
                      pieceField,
                      const SizedBox(height: AppDimensions.spacingMd),
                      addButton,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 2, child: workTypeField),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(flex: 2, child: workField),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(child: pieceField),
                    const SizedBox(width: AppDimensions.spacingMd),
                    SizedBox(width: 110, child: addButton),
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

/// Pending Work (left) and Cart Work (right), side by side on tablet width
/// — stacked on phone width, same responsive convention as [_WorkFormCard]
/// above — with Completed Work moved below, full width, same as its
/// original single-card appearance.
class _PendingAndCompletedWorkRow extends StatelessWidget {
  const _PendingAndCompletedWorkRow({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet =
            constraints.maxWidth >= AppDimensions.breakpointPhone;
        final Widget pending = _PendingWorkCard(controller: controller);
        final Widget cart = _CartWorkCard(controller: controller);
        final Widget completed = _CompletedWorkCard(controller: controller);

        final Widget topRow = !isTablet
            ? Column(
                children: [
                  pending,
                  const SizedBox(height: AppDimensions.spacingMd),
                  cart,
                ],
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: pending),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(child: cart),
                  ],
                ),
              );

        return Column(
          children: [
            topRow,
            const SizedBox(height: AppDimensions.spacingMd),
            completed,
          ],
        );
      },
    );
  }
}

/// The "Pending Work" card — bound to `BagDoneDetail`'s `PndPred` array
/// (`controller.recordedSettings`). Rows are tappable: selecting one adds
/// it into Cart Work (see [_CartWorkCard]) without removing it from here —
/// instead the row is shown disabled (dimmed, no longer tappable) for as
/// long as it's present in the cart, and re-enables itself automatically
/// once it's deleted back out of Cart Work. No delete button of its own
/// any more — Cart Work's is the only one. Table styled with the same
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
      headerPadding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingXs,
      ),
      titleFontSize: 17,
      iconSize: 17,
      child: Obx(() {
        final List<SettingEntry> entries = controller.recordedSettings;
        // Read here too, inside this same Obx, so a row's disabled state
        // — driven off Cart Work's own Set IDs — reacts to every Cart
        // Work change (add, merge, or delete), not just Pending Work's own.
        final Set<int?> cartSetIds = controller.cartWork
            .map((entry) => entry.setId)
            .toSet();

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
          onRowTap: controller.selectPendingEntry,
          isRowDisabled: (rowIndex) =>
              cartSetIds.contains(entries[rowIndex].setId),
        );
      }),
    );
  }
}

/// The "Cart Work" card — everything actually staged for submission: added
/// directly here by the Add Dummy Work Entry form (`controller.addEntry`)
/// or moved in from Pending Work by tapping a row there
/// (`controller.selectPendingEntry`). Same columns/styling as Pending
/// Work; the delete button that used to live on Pending Work now lives
/// here instead, since Cart Work is the only table rows get removed from
/// outright.
class _CartWorkCard extends StatelessWidget {
  const _CartWorkCard({required this.controller});

  final BagCompletionController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.cartWork,
      icon: Icons.shopping_cart_outlined,
      accentColor: AppColors.info,
      padding: EdgeInsets.zero,
      titleFontSize: 17,
      iconSize: 17,
      headerPadding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingXs,
      ),
      child: Obx(() {
        final List<SettingEntry> entries = controller.cartWork;

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
            onTap: () => controller.removeCartEntry(rowIndex),
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
      titleFontSize: 17,
      iconSize: 17,
      headerPadding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingXs,
      ),
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
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
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
