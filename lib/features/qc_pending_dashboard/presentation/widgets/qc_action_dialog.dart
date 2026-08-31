import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/qc_repair_checklist_item_entity.dart';
import '../../domain/entities/qc_repair_qty_entity.dart';

enum QcActionMode { ok, repair }

/// Above this many items, the repair checklist splits into two side-by-side
/// columns instead of one tall list — keeps the whole thing visible on
/// screen without scrolling for a department with a long repair list.
const int _repairListSplitThreshold = 6;

/// Shown on a bag card's OK/Repair tap. Same layout both ways — a repair
/// checklist with a qty per item, and the Diamond QC Checker's name — only
/// the title/subtitle wording, accent color, and whether the qty boxes are
/// editable differ: OK means the bag already passed, so those quantities
/// stay locked at 0; Repair means they're what's actually being logged.
///
/// [checklist] is owned by the caller (`QcBagListController`, fetched fresh
/// per tap from `QCRepairList` via `GetQcRepairChecklistUseCase` — the
/// bag's own `Process` decides which repair items apply) rather than
/// hardcoded here. [diaQcCheckerName] is likewise the caller's — the
/// Diamond QC Checker is picked once, centrally, on the QC Checking (Emp
/// List) screen and applies to every bag until changed there, so this
/// dialog only displays it (no picker of its own). On Submit, [onSubmit]
/// is handed only the checklist rows the user actually gave a quantity
/// greater than zero — the caller (`QcBagListController`) owns calling
/// `BagFinalReceive` and closing this dialog on success.
class QcActionDialog extends StatefulWidget {
  const QcActionDialog({
    required this.mode,
    required this.bagNo,
    required this.styleNo,
    required this.pieces,
    required this.checklist,
    required this.diaQcCheckerName,
    required this.onSubmit,
    super.key,
  });

  final QcActionMode mode;
  final String bagNo;
  final String styleNo;
  final int pieces;
  final List<QcRepairChecklistItemEntity> checklist;
  final String? diaQcCheckerName;
  final Future<void> Function(List<QcRepairQtyEntity> repairList) onSubmit;

  static Future<void> show({
    required QcActionMode mode,
    required String bagNo,
    required String styleNo,
    required int pieces,
    required List<QcRepairChecklistItemEntity> checklist,
    required String? diaQcCheckerName,
    required Future<void> Function(List<QcRepairQtyEntity> repairList) onSubmit,
  }) {
    return Get.dialog<void>(
      QcActionDialog(
        mode: mode,
        bagNo: bagNo,
        styleNo: styleNo,
        pieces: pieces,
        checklist: checklist,
        diaQcCheckerName: diaQcCheckerName,
        onSubmit: onSubmit,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<QcActionDialog> createState() => _QcActionDialogState();
}

class _QcActionDialogState extends State<QcActionDialog> {
  late final Map<String, TextEditingController> _qtyControllers = {
    for (final item in widget.checklist) item.id: TextEditingController(text: '0'),
  };

  // Shown on the Submit button while `BagFinalReceive` is in flight — also
  // guards Cancel/close so nothing else pops this dialog mid-submit.
  // Deliberately *not* a second `Get.dialog` loading overlay stacked on
  // top of this one, to keep only one dialog in play at a time (see
  // `QcBagListController._submitAction` for the actual close-before-
  // snackbar fix this dialog relies on).
  bool _submitting = false;

  bool get _isOk => widget.mode == QcActionMode.ok;
  Color get _accent => _isOk ? AppColors.success : AppColors.warning;

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
    final int next = (current + delta).clamp(0, 99);
    controller.text = '$next';
  }

  bool get _hasAtLeastOneRepairQty =>
      _qtyControllers.values.any((controller) => (int.tryParse(controller.text) ?? 0) > 0);

  Future<void> _submit() async {
    if (!_isOk && !_hasAtLeastOneRepairQty) {
      AppSnackbar.show(title: AppStrings.alertWarning, message: AppStrings.repairQtyRequired, isSuccess: false);
      return;
    }
    final List<QcRepairQtyEntity> repairList = [
      for (final item in widget.checklist)
        if ((int.tryParse(_qtyControllers[item.id]!.text) ?? 0) > 0)
          QcRepairQtyEntity(repairId: int.tryParse(item.id) ?? 0, qty: int.parse(_qtyControllers[item.id]!.text)),
    ];
    setState(() => _submitting = true);
    await widget.onSubmit(repairList);
    // A successful submit already popped this dialog (see
    // `QcBagListController._submitAction`) — only reset on a failed one,
    // which leaves it open so the user can fix and retry.
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final String? diaQcCheckerName = widget.diaQcCheckerName;
    final bool splitRepairList = widget.checklist.length > _repairListSplitThreshold;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: splitRepairList ? AppDimensions.qcActionDialogWideMaxWidth : AppDimensions.qcActionDialogMaxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, color: _accent),
            // The dialog's own height is otherwise fixed — without this,
            // focusing the Qty field opens the keyboard, the available
            // height shrinks, and the Column below overflows instead of
            // scrolling out of the keyboard's way.
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration:
                              BoxDecoration(color: _accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: Icon(
                            _isOk ? Icons.check_circle_outline : Icons.build_outlined,
                            color: _accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _HeaderField(label: AppStrings.bagNoShort, value: widget.bagNo),
                              ),
                              const _HeaderFieldDivider(),
                              Expanded(
                                flex: 3,
                                child: _HeaderField(label: AppStrings.styleNo, value: widget.styleNo),
                              ),
                              const _HeaderFieldDivider(),
                              Expanded(
                                flex: 2,
                                child: _HeaderField(label: AppStrings.totalPcs, value: '${widget.pieces}'),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                          onTap: _submitting ? null : () => Get.back<void>(),
                          child: const Padding(
                            padding: EdgeInsets.all(AppDimensions.spacingXxs),
                            child: Icon(Icons.close, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    _RepairTable(
                      checklist: widget.checklist,
                      qtyControllers: _qtyControllers,
                      qtyEnabled: !_isOk,
                      onStep: _step,
                    ),
                    if (diaQcCheckerName != null) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      Row(
                        children: [
                          const Icon(Icons.diamond_outlined, size: AppDimensions.iconSm, color: AppColors.primary),
                          const SizedBox(width: AppDimensions.spacingXxs),
                          Text(
                            AppStrings.diamondQcStatus,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      _DiaQcCheckerDisplay(name: diaQcCheckerName),
                    ],
                    const SizedBox(height: AppDimensions.spacingMd),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: AppStrings.cancel,
                          variant: AppButtonVariant.outlined,
                          fullWidth: false,
                          onPressed: _submitting ? null : () => Get.back<void>(),
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        AppButton(
                          label: AppStrings.submitQc,
                          fullWidth: false,
                          isLoading: _submitting,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One "label above value" segment of the header's Bag No. / Style No. /
/// Pcs row.
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
      child: SizedBox(height: 32, child: VerticalDivider(width: 1, color: AppColors.divider)),
    );
  }
}

class _RepairTable extends StatelessWidget {
  const _RepairTable({
    required this.checklist,
    required this.qtyControllers,
    required this.qtyEnabled,
    required this.onStep,
  });

  final List<QcRepairChecklistItemEntity> checklist;
  final Map<String, TextEditingController> qtyControllers;
  final bool qtyEnabled;
  final void Function(String itemId, int delta) onStep;

  @override
  Widget build(BuildContext context) {
    if (checklist.length <= _repairListSplitThreshold) {
      return _RepairTableColumn(
        checklist: checklist,
        qtyControllers: qtyControllers,
        qtyEnabled: qtyEnabled,
        onStep: onStep,
      );
    }

    // Split into two side-by-side columns once the list gets long, each
    // scrolling internally with a fixed max height — so the dialog's own
    // height (and its OK/Cancel buttons) stays fixed regardless of list
    // length, instead of the whole dialog growing/scrolling.
    final int half = (checklist.length / 2).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RepairTableColumn(
            checklist: checklist.sublist(0, half),
            qtyControllers: qtyControllers,
            qtyEnabled: qtyEnabled,
            onStep: onStep,
            maxHeight: AppDimensions.qcActionSplitColumnMaxHeight,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: _RepairTableColumn(
            checklist: checklist.sublist(half),
            qtyControllers: qtyControllers,
            qtyEnabled: qtyEnabled,
            onStep: onStep,
            maxHeight: AppDimensions.qcActionSplitColumnMaxHeight,
          ),
        ),
      ],
    );
  }
}

/// One bordered repair-checklist table — either the whole list (no height
/// cap, [maxHeight] left `null`), or one half of it when [QcActionDialog]
/// splits a long list into two side-by-side columns, each capped at
/// [maxHeight] and scrolling internally (see [_RepairTable]).
class _RepairTableColumn extends StatelessWidget {
  const _RepairTableColumn({
    required this.checklist,
    required this.qtyControllers,
    required this.qtyEnabled,
    required this.onStep,
    this.maxHeight,
  });

  final List<QcRepairChecklistItemEntity> checklist;
  final Map<String, TextEditingController> qtyControllers;
  final bool qtyEnabled;
  final void Function(String itemId, int delta) onStep;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final double qtyColumnWidth =
        qtyEnabled ? AppDimensions.qcActionQtyStepperWidth : AppDimensions.qcActionQtyBoxSize;

    final List<Widget> rows = [
      for (int i = 0; i < checklist.length; i++)
        DecoratedBox(
          decoration: BoxDecoration(
            color: i.isOdd ? AppColors.background : AppColors.surface,
            border: i == checklist.length - 1 ? null : const Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingXxs,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: AppDimensions.qcActionRepairIdColumnWidth,
                  child: Text(
                    checklist[i].id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(checklist[i].label, style: Theme.of(context).textTheme.bodyMedium),
                ),
                SizedBox(
                  width: qtyColumnWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: qtyEnabled
                        ? _QtyStepper(
                            controller: qtyControllers[checklist[i].id]!,
                            onStep: (delta) => onStep(checklist[i].id, delta),
                          )
                        : _QtyBox(controller: qtyControllers[checklist[i].id]!, enabled: false),
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
                  SizedBox(
                    width: AppDimensions.qcActionRepairIdColumnWidth,
                    child: _HeaderLabel(AppStrings.repairIdColumn),
                  ),
                  Expanded(child: _HeaderLabel(AppStrings.repairColumn)),
                  SizedBox(
                    width: qtyColumnWidth,
                    child: _HeaderLabel(AppStrings.qtyColumn, alignEnd: true),
                  ),
                ],
              ),
            ),
          ),
          if (checklist.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingLg),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else if (maxHeight != null)
            // Split-column case: capped and scrolls internally, so the
            // dialog's own height — and its OK/Cancel buttons — stays
            // fixed regardless of how long this half of the list is.
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

class _QtyBox extends StatelessWidget {
  const _QtyBox({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.qcActionQtyBoxSize,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primaryContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      // No underline/border at all, in any state — the app's shared text-
      // field theme otherwise still paints one under `InputBorder.none`
      // alone, since `enabledBorder`/`focusedBorder` win over the base
      // `border` once the theme sets them.
      child: TextField(
        controller: controller,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        // Plain numeric entry only — no text-selection handles/magnifier
        // (the "oval" that shows up when tapping into such a small field).
        enableInteractiveSelection: false,
        showCursor: enabled,
        cursorColor: AppColors.primary,
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: enabled ? AppColors.primary : AppColors.textHint,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// Repair mode's qty control — +/- buttons for quick taps, with the number
/// itself still directly editable (typing a value works too), all inside
/// one borderless chip matching [_QtyBox]'s look.
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
                disabledBorder: InputBorder.none,
                filled: false,
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

/// Read-only — the Diamond QC Checker is picked once, centrally, on the QC
/// Checking (Emp List) screen, not per bag. Styled to match the same
/// filled/bordered field look the picker used to have, just without a
/// dropdown affordance. Only ever shown once a checker is actually
/// selected — see the `if (widget.diaQcCheckerName != null)` guard above.
class _DiaQcCheckerDisplay extends StatelessWidget {
  const _DiaQcCheckerDisplay({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
