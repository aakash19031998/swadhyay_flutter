import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_repair_checklist_item_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_repair_qty_entity.dart';

/// Bag Info + Repair Details, shown side by side once a bag is found on the
/// QC Checker screen — same repair-checklist quantities/submit shape as
/// `QcActionDialog` (QC Pending Dashboard's OK/Repair popup), just laid out
/// as an always-visible two-panel screen section instead of a modal, and
/// with "OK (Pass QC)"/"Submit Repair Details" as two direct actions
/// instead of one dialog opened from a card tap.
class QcRepairDetailsPanel extends StatefulWidget {
  const QcRepairDetailsPanel({
    required this.bag,
    required this.checklist,
    required this.isLoadingChecklist,
    required this.checkerName,
    required this.isSubmittingOk,
    required this.isSubmittingRepair,
    required this.onOk,
    required this.onSubmitRepair,
    super.key,
  });

  final QcAssignedBagEntity? bag;
  final List<QcRepairChecklistItemEntity> checklist;
  final bool isLoadingChecklist;
  final String? checkerName;
  final bool isSubmittingOk;
  final bool isSubmittingRepair;
  final VoidCallback? onOk;
  final ValueChanged<List<QcRepairQtyEntity>>? onSubmitRepair;

  @override
  State<QcRepairDetailsPanel> createState() => _QcRepairDetailsPanelState();
}

class _QcRepairDetailsPanelState extends State<QcRepairDetailsPanel> {
  Map<String, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant QcRepairDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `checklist` is fed straight from an `RxList` (`assignAll` mutates
    // that same list in place rather than replacing it), so `identical()`
    // never sees a change once the real checklist arrives after the
    // initial (empty) build — comparing ids instead is what actually
    // detects that, and is what `_RepairTableColumn` needs to avoid
    // looking up a qty controller that was never created.
    final bool sameIds =
        oldWidget.checklist.length == widget.checklist.length &&
        _qtyControllers.length == widget.checklist.length &&
        widget.checklist.every((item) => _qtyControllers.containsKey(item.id));
    if (!sameIds) _syncControllers();
  }

  // Rebuilt whenever the checklist itself changes (a different bag was
  // found, or the real data finished loading) — not on every quantity
  // edit, which only mutates the existing controllers in place via `_step`.
  void _syncControllers() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _qtyControllers = {
      for (final item in widget.checklist)
        item.id: TextEditingController(text: '0'),
    };
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _step(String itemId, int delta) {
    final TextEditingController? controller = _qtyControllers[itemId];
    if (controller == null) return;
    final int current = int.tryParse(controller.text) ?? 0;
    setState(() => controller.text = '${(current + delta).clamp(0, 99)}');
  }

  void _submitRepair() {
    final bool hasQty = _qtyControllers.values.any(
      (controller) => (int.tryParse(controller.text) ?? 0) > 0,
    );
    if (!hasQty) {
      AppSnackbar.show(
        title: AppStrings.alertWarning,
        message: AppStrings.repairQtyRequired,
        isSuccess: false,
      );
      return;
    }
    final List<QcRepairQtyEntity> repairList = [
      for (final item in widget.checklist)
        if ((int.tryParse(_qtyControllers[item.id]!.text) ?? 0) > 0)
          QcRepairQtyEntity(
            repairId: int.tryParse(item.id) ?? 0,
            qty: int.parse(_qtyControllers[item.id]!.text),
          ),
    ];
    widget.onSubmitRepair?.call(repairList);
  }

  @override
  Widget build(BuildContext context) {
    // Fills the whole screen (rather than a `SingleChildScrollView` sized
    // to its own content) so both cards' white backgrounds stretch all the
    // way to the bottom instead of leaving the scaffold's background
    // exposed below them. Each card scrolls its own body internally (see
    // `_BagInfoCard`/`_RepairDetailsCard`) so a shrunk height — e.g. the
    // keyboard opening for a repair qty — clips safely instead of
    // overflowing.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shown once, above both cards, since the Diamond QC Checker
        // isn't specific to either one — it applies to whatever action
        // (OK on the Bag Info card, or Submit Repair Details on the
        // Repair Details card) ends up being taken on this bag.
        _DiamondQcCheckerBanner(checkerName: widget.checkerName),
        const SizedBox(height: AppDimensions.spacingMd),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: _BagInfoCard(
                  bag: widget.bag,
                  onOk: widget.onOk,
                  isSubmittingOk: widget.isSubmittingOk,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                flex: 3,
                child: _RepairDetailsCard(
                  bag: widget.bag,
                  checklist: widget.checklist,
                  isLoading: widget.isLoadingChecklist,
                  qtyControllers: _qtyControllers,
                  onStep: _step,
                  isSubmitting: widget.isSubmittingRepair,
                  onSubmit: widget.onSubmitRepair == null
                      ? null
                      : _submitRepair,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The Diamond QC Checker selected centrally on the QC Checker screen —
/// common to both cards below (not shown twice, once per card), so it gets
/// its own banner instead of being tucked into either one's footer.
class _DiamondQcCheckerBanner extends StatelessWidget {
  const _DiamondQcCheckerBanner({required this.checkerName});

  final String? checkerName;

  @override
  Widget build(BuildContext context) {
    final bool selected = checkerName != null;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Slim accent stripe instead of a full solid-color background —
          // enough to give the card an identity without dominating it.
          Container(
            width: 5,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diamond_outlined,
                      color: AppColors.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DIAMOND QC CHECKER',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                        Text(
                          checkerName ?? 'Not selected yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                                fontWeight: FontWeight.w800,
                                fontStyle: selected
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BagInfoCard extends StatelessWidget {
  const _BagInfoCard({
    required this.bag,
    required this.onOk,
    required this.isSubmittingOk,
  });

  final QcAssignedBagEntity? bag;
  final VoidCallback? onOk;
  final bool isSubmittingOk;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              0,
            ),
            child: _BagImageBanner(
              imageUrl: bag?.imageUrl,
              pieces: bag?.pieces ?? 0,
            ),
          ),
          // `Expanded` + internal scroll (rather than sizing to content)
          // so the card's white background stretches down to fill
          // whatever height the Repair Details card next to it ends up
          // needing, instead of leaving a gap below the OK button.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bag?.bagNo ?? '—',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  _StatTile(
                    icon: Icons.autorenew,
                    label: 'Process',
                    value: bag == null || bag!.process.isEmpty
                        ? '—'
                        : bag!.process,
                    accent: AppColors.success,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  _StatTile(
                    icon: Icons.style_outlined,
                    label: 'Style Number',
                    value: bag == null || bag!.style.isEmpty ? '—' : bag!.style,
                    accent: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  _StatTile(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Order Number',
                    value: bag == null || bag!.orderNo.isEmpty
                        ? '—'
                        : bag!.orderNo,
                    accent: AppColors.info,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  _StatTile(
                    icon: Icons.event_available_outlined,
                    label: AppStrings.firstReceived,
                    value: bag == null
                        ? '—'
                        : DateTimeHelper.formatDateTimeColonSeconds(
                            bag!.firstRecDate,
                          ),
                    accent: AppColors.warning,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onOk,
                      icon: isSubmittingOk
                          ? const SizedBox(
                              width: AppDimensions.iconSm,
                              height: AppDimensions.iconSm,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.onPrimary,
                            ),
                      label: Text(
                        'OK (Pass QC)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingSm + 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width photo banner at the top of the card, with the piece-count
/// pill overlaid on its top-right corner instead of sitting in a separate
/// row below — no filled backing behind the image itself (a solid card and
/// a translucent ring were both tried and didn't land), just a clipped
/// rounded rect and a soft shadow for lift.
class _BagImageBanner extends StatelessWidget {
  const _BagImageBanner({required this.imageUrl, required this.pieces});

  final String? imageUrl;
  final int pieces;

  static const double _height = 170;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: _height,
              child: imageUrl == null
                  ? const ColoredBox(
                      color: AppColors.background,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.textHint,
                        size: AppDimensions.iconXl,
                      ),
                    )
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const ColoredBox(
                          color: AppColors.background,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: AppColors.background,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textHint,
                              size: AppDimensions.iconXl,
                            ),
                          ),
                    ),
            ),
            Positioned(
              top: AppDimensions.spacingSm,
              right: AppDimensions.spacingSm,
              child: _Pill(
                icon: Icons.diamond_outlined,
                label: '$pieces ${AppStrings.totalPcs}',
                background: AppColors.warningContainer,
                foreground: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rectangular (not pill-shaped) chip showing both a small uppercase title
/// and its value — used for Order Number/First Received, where the title
/// matters (unlike [_Pill]'s icon-only-implies-meaning process/pieces
/// chips above it).
/// Full-width "dashboard stat" row — an accent-tinted icon roundel, a small
/// uppercase title, and the value underneath. Reads as one clean list
/// (matches the sidebar's own department-list rhythm) rather than chips
/// that had to wrap awkwardly at this card's width.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
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

class _RepairDetailsCard extends StatelessWidget {
  const _RepairDetailsCard({
    required this.bag,
    required this.checklist,
    required this.isLoading,
    required this.qtyControllers,
    required this.onStep,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final QcAssignedBagEntity? bag;
  final List<QcRepairChecklistItemEntity> checklist;
  final bool isLoading;
  final Map<String, TextEditingController> qtyControllers;
  final void Function(String itemId, int delta) onStep;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.build_outlined,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _HeaderField(
                          label: AppStrings.bagNoShort,
                          value: bag?.bagNo ?? '—',
                        ),
                      ),
                      const _HeaderFieldDivider(),
                      Expanded(
                        flex: 3,
                        child: _HeaderField(
                          label: AppStrings.orderNo,
                          value: bag?.orderNo ?? '—',
                        ),
                      ),
                      const _HeaderFieldDivider(),
                      Expanded(
                        flex: 2,
                        child: _HeaderField(
                          label: AppStrings.totalPcs,
                          value: '${bag?.pieces ?? 0}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // `Expanded` + internal scroll (rather than sizing to content) so
          // the card's white background/border stretches down to fill the
          // full available height instead of leaving a gap below the
          // Submit Repair button.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingLg),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : checklist.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingLg),
                      child: Center(child: Text(AppStrings.noDataFound)),
                    )
                  : _RepairTable(
                      checklist: checklist,
                      qtyControllers: qtyControllers,
                      onStep: onStep,
                    ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: onSubmit,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: AppDimensions.iconSm,
                            height: AppDimensions.iconSm,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.onPrimary,
                          ),
                    label: Text(
                      'Submit Repair',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingSm + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
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

/// One "label above value" segment of the header's Bag No. / Style No. /
/// Pcs row — same shape as `QcActionDialog`'s own `_HeaderField`.
class _HeaderField extends StatelessWidget {
  const _HeaderField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _HeaderFieldDivider extends StatelessWidget {
  const _HeaderFieldDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm),
      child: SizedBox(
        height: 32,
        child: VerticalDivider(width: 1, color: AppColors.divider),
      ),
    );
  }
}

/// Reactively styled off the controller's own value — no qty (the default)
/// reads as a plain, unselected chip; any qty > 0 flips it to an
/// error-tinted "this defect is flagged" chip, including a filled numbered
/// badge in place of the plain "(id)" prefix the previous design used.
/// Same bordered table as `QcActionDialog`'s own `_RepairTableColumn` (QC
/// Pending Dashboard's OK/Repair popup) — a header row (ID / Repair / Qty)
/// then one full-width row per defect, instead of the earlier 2-column
/// chip grid. Always editable here (no locked/OK-mode qty box variant),
/// since this screen has separate OK and Submit Repair Details buttons
/// rather than one dialog that switches mode.
/// Above this many items, the table splits into two side-by-side columns
/// instead of one tall list — same threshold/reasoning as `QcActionDialog`'s
/// own `_repairListSplitThreshold`.
const int _repairListSplitThreshold = 6;

class _RepairTable extends StatelessWidget {
  const _RepairTable({
    required this.checklist,
    required this.qtyControllers,
    required this.onStep,
  });

  final List<QcRepairChecklistItemEntity> checklist;
  final Map<String, TextEditingController> qtyControllers;
  final void Function(String itemId, int delta) onStep;

  @override
  Widget build(BuildContext context) {
    if (checklist.length <= _repairListSplitThreshold) {
      return _RepairTableColumn(
        checklist: checklist,
        qtyControllers: qtyControllers,
        onStep: onStep,
      );
    }

    // Split into two side-by-side columns once the list gets long, each
    // scrolling internally with a fixed max height.
    final int half = (checklist.length / 2).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RepairTableColumn(
            checklist: checklist.sublist(0, half),
            qtyControllers: qtyControllers,
            onStep: onStep,
            maxHeight: AppDimensions.qcActionSplitColumnMaxHeight,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: _RepairTableColumn(
            checklist: checklist.sublist(half),
            qtyControllers: qtyControllers,
            onStep: onStep,
            maxHeight: AppDimensions.qcActionSplitColumnMaxHeight,
          ),
        ),
      ],
    );
  }
}

/// One bordered repair-checklist table — either the whole list (no height
/// cap, [maxHeight] left `null`), or one half of it when [_RepairTable]
/// splits a long list into two side-by-side columns, each capped at
/// [maxHeight] and scrolling internally. No id column — just the label and
/// its qty stepper.
class _RepairTableColumn extends StatelessWidget {
  const _RepairTableColumn({
    required this.checklist,
    required this.qtyControllers,
    required this.onStep,
    this.maxHeight,
  });

  final List<QcRepairChecklistItemEntity> checklist;
  final Map<String, TextEditingController> qtyControllers;
  final void Function(String itemId, int delta) onStep;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [
      for (int i = 0; i < checklist.length; i++)
        DecoratedBox(
          decoration: BoxDecoration(
            color: i.isOdd ? AppColors.background : AppColors.surface,
            border: i == checklist.length - 1
                ? null
                : const Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingXxs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    checklist[i].label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: AppDimensions.qcActionQtyStepperWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _QtyStepper(
                      controller: qtyControllers[checklist[i].id]!,
                      onStep: (delta) => onStep(checklist[i].id, delta),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.background),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              child: Row(
                children: [
                  Expanded(child: _HeaderLabel(AppStrings.repairColumn)),
                  SizedBox(
                    width: AppDimensions.qcActionQtyStepperWidth,
                    child: _HeaderLabel(AppStrings.qtyColumn, alignEnd: true),
                  ),
                ],
              ),
            ),
          ),
          if (maxHeight != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: SingleChildScrollView(child: Column(children: rows)),
            )
          else
            ...rows,
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label, {this.alignEnd = false});

  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// +/- qty control — matches `QcActionDialog`'s own `_QtyStepper`.
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.controller, required this.onStep});

  final TextEditingController controller;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.qcActionQtyStepperWidth,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: () => onStep(-1)),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enableInteractiveSelection: false,
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: () => onStep(1)),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
