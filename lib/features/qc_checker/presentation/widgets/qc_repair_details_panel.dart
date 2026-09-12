import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_repair_checklist_item_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_repair_qty_entity.dart';

/// Bag Info + Repair Details, shown side by side once a bag is found on the
/// QC Checker screen. The Bag Info card has no action button of its own any
/// more — the Repair Details card's own "All Passed" toggle/Pass Pieces qty
/// entry plus its repair checklist table is the one place that finalizes QC
/// for the bag: "Submit Inspection (All Passed)" reuses [onOk] exactly as
/// the old OK button did, and "Submit Repair" reuses [onSubmitRepair]
/// exactly as it always has (a qty per defect type, via
/// [QcRepairChecklistItemEntity]).
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
  final TextEditingController _passQtyController = TextEditingController(
    text: '0',
  );
  bool _allPassed = false;
  bool _touched = false;
  int _currentPieceIndex = 0;

  // One qty-per-defect-type table's worth of controllers per repair piece
  // — same `_RepairTable` widget as before, just scoped to whichever piece
  // is currently selected instead of one shared table for the whole bag.
  List<Map<String, TextEditingController>> _pieceQtyControllers = [];

  int get _totalPieces => widget.bag?.pieces ?? 0;

  int get _passQty => _allPassed
      ? _totalPieces
      : (int.tryParse(_passQtyController.text) ?? 0).clamp(0, _totalPieces);

  int get _repairQty => (_totalPieces - _passQty).clamp(0, _totalPieces);

  bool get _currentPieceHasQty =>
      _currentPieceIndex < _pieceQtyControllers.length &&
      _pieceQtyControllers[_currentPieceIndex].values.any(
        (controller) => (int.tryParse(controller.text) ?? 0) > 0,
      );

  bool get _isLastPiece => _currentPieceIndex >= _repairQty - 1;

  @override
  void initState() {
    super.initState();
    _rebuildAllPieceControllers();
  }

  @override
  void didUpdateWidget(covariant QcRepairDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `checklist` is fed straight from an `RxList` (`assignAll` mutates
    // that same list in place rather than replacing it), so `identical()`
    // never sees a change once the real checklist arrives after the
    // initial (empty) build — comparing ids instead is what actually
    // detects that. Pieces at that point have no entered data worth
    // preserving, so this just rebuilds every piece's table fresh.
    final bool sameIds =
        oldWidget.checklist.length == widget.checklist.length &&
        widget.checklist.every(
          (item) => _pieceQtyControllers.every((m) => m.containsKey(item.id)),
        );
    if (!sameIds) _rebuildAllPieceControllers();
  }

  void _rebuildAllPieceControllers() {
    for (final map in _pieceQtyControllers) {
      for (final controller in map.values) {
        controller.dispose();
      }
    }
    _pieceQtyControllers = [
      for (int i = 0; i < _repairQty; i++) _newPieceControllers(),
    ];
  }

  Map<String, TextEditingController> _newPieceControllers() => {
    for (final item in widget.checklist)
      item.id: TextEditingController(text: '0'),
  };

  // Keeps one qty-table's worth of controllers per repair piece in step
  // with [_repairQty] — grown/trimmed (preserving whatever quantities
  // survive) every time the pass/all-passed inputs change [_repairQty]
  // itself.
  void _syncPieceControllers() {
    final int count = _repairQty;
    while (_pieceQtyControllers.length > count) {
      final map = _pieceQtyControllers.removeLast();
      for (final controller in map.values) {
        controller.dispose();
      }
    }
    while (_pieceQtyControllers.length < count) {
      _pieceQtyControllers.add(_newPieceControllers());
    }
    if (_currentPieceIndex >= count) {
      _currentPieceIndex = count == 0 ? 0 : count - 1;
    }
  }

  @override
  void dispose() {
    _passQtyController.dispose();
    for (final map in _pieceQtyControllers) {
      for (final controller in map.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _onAllPassedChanged(bool value) {
    setState(() {
      _allPassed = value;
      _touched = value;
      _passQtyController.text = value ? '$_totalPieces' : '0';
      _currentPieceIndex = 0;
      _syncPieceControllers();
    });
  }

  // Stepping the pass qty back down to 0 is the documented way to
  // re-enable the "All Passed" toggle — treated the same as never having
  // touched this bag's inspection at all, back to the "Awaiting QC Input"
  // state.
  void _onPassQtyStep(int delta) {
    final int current = int.tryParse(_passQtyController.text) ?? 0;
    final int next = (current + delta).clamp(0, _totalPieces);
    setState(() {
      _passQtyController.text = '$next';
      _touched = next > 0;
      _currentPieceIndex = 0;
      _syncPieceControllers();
    });
  }

  void _onSelectPiece(int index) => setState(() => _currentPieceIndex = index);

  void _onPreviousPiece() {
    setState(
      () => _currentPieceIndex = (_currentPieceIndex - 1).clamp(
        0,
        _repairQty - 1,
      ),
    );
  }

  void _onNextPiece() {
    setState(() {
      _currentPieceIndex = (_currentPieceIndex + 1).clamp(0, _repairQty - 1);
    });
  }

  // A single piece can only exhibit a given defect once, so its qty is
  // really just a 0/1 toggle rather than an open-ended count.
  void _stepCurrentPiece(String itemId, int delta) {
    final TextEditingController? controller =
        _pieceQtyControllers[_currentPieceIndex][itemId];
    if (controller == null) return;
    final int current = int.tryParse(controller.text) ?? 0;
    setState(() => controller.text = '${(current + delta).clamp(0, 1)}');
  }

  // Sums every piece's entered quantities into the same `QcRepairQtyEntity`
  // shape `onSubmitRepair` has always expected — one entry per defect
  // type, its qty the total across every repair piece — so the existing
  // submit/`BagFinalReceive` plumbing is completely unchanged, only how
  // the list is built (summed across per-piece tables) is new.
  void _submitRepairPieces() {
    final Map<String, int> totals = {};
    for (final pieceControllers in _pieceQtyControllers) {
      for (final entry in pieceControllers.entries) {
        final int qty = int.tryParse(entry.value.text) ?? 0;
        if (qty > 0) totals[entry.key] = (totals[entry.key] ?? 0) + qty;
      }
    }
    final List<QcRepairQtyEntity> repairList = [
      for (final entry in totals.entries)
        QcRepairQtyEntity(
          repairId: int.tryParse(entry.key) ?? 0,
          qty: entry.value,
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
        // the Repair Details card's own dynamic submit button ends up
        // taking on this bag (it's the only action left now the Bag Info
        // card's OK button is gone — see `_BagInfoCard`).
        _DiamondQcCheckerBanner(checkerName: widget.checkerName),
        const SizedBox(height: AppDimensions.spacingMd),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 1, child: _BagInfoCard(bag: widget.bag)),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                flex: 3,
                child: _RepairDetailsCard(
                  checklist: widget.checklist,
                  isLoading: widget.isLoadingChecklist,
                  totalPieces: _totalPieces,
                  passQtyController: _passQtyController,
                  allPassed: _allPassed,
                  touched: _touched,
                  passQty: _passQty,
                  repairQty: _repairQty,
                  currentPieceIndex: _currentPieceIndex,
                  pieceQtyControllers: _pieceQtyControllers,
                  isLastPiece: _isLastPiece,
                  currentPieceHasQty: _currentPieceHasQty,
                  onAllPassedChanged: _onAllPassedChanged,
                  onPassQtyStep: _onPassQtyStep,
                  onSelectPiece: _onSelectPiece,
                  onStepCurrentPiece: _stepCurrentPiece,
                  onPreviousPiece: _onPreviousPiece,
                  onNextPiece: _onNextPiece,
                  isSubmittingOk: widget.isSubmittingOk,
                  isSubmittingRepair: widget.isSubmittingRepair,
                  onSubmitAllPassed: widget.onOk,
                  onSubmitRepairFinal: widget.onSubmitRepair == null
                      ? null
                      : _submitRepairPieces,
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
  const _BagInfoCard({required this.bag});

  final QcAssignedBagEntity? bag;

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
            child: _BagImageBanner(imageUrl: bag?.imageUrl),
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
                  // Moved here from an overlay pill on the image banner
                  // above — same tile style as every other field in this
                  // card now, instead of a standalone chip.
                  _StatTile(
                    icon: Icons.diamond_outlined,
                    label: AppStrings.totalPcs,
                    value: '${bag?.pieces ?? 0}',
                    accent: AppColors.warning,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width photo banner at the top of the card — no filled backing
/// behind the image itself (a solid card and a translucent ring were both
/// tried and didn't land), just a clipped rounded rect and a soft shadow
/// for lift. The piece-count pill that used to overlay its top-right
/// corner now lives in the card body instead, below Style Number (see
/// [_BagInfoCard]).
class _BagImageBanner extends StatelessWidget {
  const _BagImageBanner({required this.imageUrl});

  final String? imageUrl;

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
        child: SizedBox(
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
      ),
    );
  }
}

/// Full-width "dashboard stat" row — an accent-tinted icon roundel, a small
/// uppercase title, and the value underneath. Reads as one clean list
/// (matches the sidebar's own department-list rhythm) rather than chips
/// that had to wrap awkwardly at this card's width. Also used for the
/// piece count now (moved here from an overlay pill on the image banner),
/// so every field in this card reads the same way.
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

/// The "All Passed" toggle + Pass Pieces qty entry, followed by whichever
/// of three states currently applies: nothing entered yet
/// ([_AwaitingQcInputCard]), the whole lot passed ([_WholeLotClearedCard]),
/// or one-piece-at-a-time repair inspection ([_RepairPiecesSection] — the
/// same [_RepairTable] qty-per-defect-type table as before, just scoped to
/// whichever repair piece is currently selected). [totalPieces]/[passQty]/
/// [repairQty] and the per-piece qty tables are all owned and derived by
/// [_QcRepairDetailsPanelState] — this card is purely presentational.
class _RepairDetailsCard extends StatelessWidget {
  const _RepairDetailsCard({
    required this.checklist,
    required this.isLoading,
    required this.totalPieces,
    required this.passQtyController,
    required this.allPassed,
    required this.touched,
    required this.passQty,
    required this.repairQty,
    required this.currentPieceIndex,
    required this.pieceQtyControllers,
    required this.isLastPiece,
    required this.currentPieceHasQty,
    required this.onAllPassedChanged,
    required this.onPassQtyStep,
    required this.onSelectPiece,
    required this.onStepCurrentPiece,
    required this.onPreviousPiece,
    required this.onNextPiece,
    required this.isSubmittingOk,
    required this.isSubmittingRepair,
    required this.onSubmitAllPassed,
    required this.onSubmitRepairFinal,
  });

  final List<QcRepairChecklistItemEntity> checklist;
  final bool isLoading;
  final int totalPieces;
  final TextEditingController passQtyController;
  final bool allPassed;
  final bool touched;
  final int passQty;
  final int repairQty;
  final int currentPieceIndex;
  final List<Map<String, TextEditingController>> pieceQtyControllers;
  final bool isLastPiece;
  final bool currentPieceHasQty;
  final ValueChanged<bool> onAllPassedChanged;
  final ValueChanged<int> onPassQtyStep;
  final ValueChanged<int> onSelectPiece;
  final void Function(String itemId, int delta) onStepCurrentPiece;
  final VoidCallback onPreviousPiece;
  final VoidCallback onNextPiece;
  final bool isSubmittingOk;
  final bool isSubmittingRepair;
  final VoidCallback? onSubmitAllPassed;
  final VoidCallback? onSubmitRepairFinal;

  bool get _isCleared => touched && repairQty == 0;

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
          // `Expanded` + internal scroll (rather than sizing to content) so
          // the card's white background/border stretches down to fill the
          // full available height instead of leaving a gap below the
          // bottom action button.
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // `IntrinsicHeight` is required here: a bare `Row`
                        // with `CrossAxisAlignment.stretch` inside this
                        // `SingleChildScrollView`'s unbounded-height Column
                        // throws "BoxConstraints forces an infinite height"
                        // — the Row has nothing finite to stretch its
                        // children to without it.
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _AllPassedToggleCard(
                                  totalPieces: totalPieces,
                                  value: allPassed,
                                  // A manually entered pass qty > 0 locks
                                  // the toggle until it's reset back to 0
                                  // — see `_QcRepairDetailsPanelState.
                                  // _onPassQtyChanged`.
                                  enabled:
                                      allPassed || !touched || passQty == 0,
                                  onChanged: onAllPassedChanged,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              Expanded(
                                child: _PassQtyCard(
                                  controller: passQtyController,
                                  enabled: !allPassed,
                                  onStep: onPassQtyStep,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        if (!touched)
                          _AwaitingQcInputCard(totalPieces: totalPieces)
                        else if (_isCleared)
                          _WholeLotClearedCard(totalPieces: totalPieces)
                        else if (checklist.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(AppDimensions.spacingLg),
                            child: Center(child: Text(AppStrings.noDataFound)),
                          )
                        else
                          _RepairPiecesSection(
                            checklist: checklist,
                            passQty: passQty,
                            repairQty: repairQty,
                            currentPieceIndex: currentPieceIndex,
                            pieceQtyControllers: pieceQtyControllers,
                            onSelectPiece: onSelectPiece,
                            onStep: onStepCurrentPiece,
                          ),
                      ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  child: AppButton(
                    label: AppStrings.cancel,
                    variant: AppButtonVariant.outlined,
                    onPressed: Get.back,
                  ),
                ),
                Row(
                  children: [
                    // Only shown once the user has moved past the first
                    // repair piece — nothing to go "back" to before that.
                    if (touched && !_isCleared && currentPieceIndex > 0) ...[
                      SizedBox(
                        width: 190,
                        child: AppButton(
                          label: 'Previous (#$currentPieceIndex)',
                          variant: AppButtonVariant.outlined,
                          onPressed: onPreviousPiece,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                    ],
                    // Wide enough for the longest label ("Submit Inspection
                    // (All Passed)") without ellipsis-truncating it.
                    SizedBox(width: 320, child: _buildActionButton()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (!touched) {
      return const _SubmitButton(
        label: 'Submit Inspection',
        icon: Icons.send_rounded,
        color: AppColors.disabled,
        onPressed: null,
        isLoading: false,
      );
    }

    if (_isCleared) {
      return _SubmitButton(
        label: 'Submit Inspection (All Passed)',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        onPressed: onSubmitAllPassed,
        isLoading: isSubmittingOk,
      );
    }

    if (!isLastPiece) {
      return _SubmitButton(
        label: 'Next (Piece #${currentPieceIndex + 2})',
        icon: Icons.arrow_forward_rounded,
        color: currentPieceHasQty ? AppColors.primary : AppColors.disabled,
        onPressed: currentPieceHasQty ? onNextPiece : null,
        isLoading: false,
      );
    }

    return _SubmitButton(
      label:
          'Submit Inspection ($repairQty '
          'Repair${repairQty == 1 ? '' : 's'})',
      icon: Icons.send_rounded,
      color: currentPieceHasQty ? AppColors.error : AppColors.disabled,
      onPressed: currentPieceHasQty ? onSubmitRepairFinal : null,
      isLoading: isSubmittingRepair,
    );
  }
}

/// The bottom-right action button — its label/color/enabled state fully
/// driven by [_RepairDetailsCard._buildActionButton] so this widget itself
/// stays a dumb, reusable button shell.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: AppDimensions.iconSm,
              height: AppDimensions.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onPrimary,
              ),
            )
          : Icon(icon, color: AppColors.onPrimary),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingSm + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
    );
  }
}

/// The "All N Pieces Passed" toggle card. Grey/muted whenever [enabled] is
/// false — a manually entered pass qty > 0 locks it — with the caption
/// text itself explaining why.
class _AllPassedToggleCard extends StatelessWidget {
  const _AllPassedToggleCard({
    required this.totalPieces,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int totalPieces;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = value ? AppColors.success : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? AppColors.successContainer : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline, size: 17, color: iconColor),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All $totalPieces Pieces Passed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: enabled ? AppColors.textPrimary : AppColors.textHint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  enabled
                      ? 'Toggle if all $totalPieces pass'
                      : 'Disabled (Reset pass count to 0 to enable)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

/// The "Pass Pieces" numeric entry — a -/+ [_PassQtyStepper]. Disabled while
/// the "All Passed" toggle is on, since the qty is then fully determined by
/// that toggle instead.
class _PassQtyCard extends StatelessWidget {
  const _PassQtyCard({
    required this.controller,
    required this.enabled,
    required this.onStep,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PASS PIECES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'Entering > 0 disables checkbox',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Opacity(
            opacity: enabled ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !enabled,
              child: _PassQtyStepper(controller: controller, onStep: onStep),
            ),
          ),
        ],
      ),
    );
  }
}

/// Default state — nothing entered yet, either toggle untouched or the
/// pass qty reset back to 0.
class _AwaitingQcInputCard extends StatelessWidget {
  const _AwaitingQcInputCard({required this.totalPieces});

  final int totalPieces;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textHint.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.textHint,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Awaiting QC Input',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Check "All $totalPieces Pieces Passed" or enter the number of '
            'Pass Pieces above to begin inspection.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The whole lot cleared QC without any repairs — either the "All Passed"
/// toggle was switched on, or a manually entered pass qty happened to reach
/// [totalPieces] on its own.
class _WholeLotClearedCard extends StatelessWidget {
  const _WholeLotClearedCard({required this.totalPieces});

  final int totalPieces;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.onPrimary,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'All Pieces are Okay',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'All $totalPieces pieces meet standard specifications '
            'without any reported defects.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// "N Passed / N Repair" pills + the dynamically generated per-piece chip
/// row + the currently selected piece's own qty-per-defect-type table
/// (the same [_RepairTable] used before, just scoped to one piece) — one
/// chip per [repairQty], since that's exactly how many pieces still need a
/// repair decision (`totalPieces - passQty`, recomputed live — see
/// `_QcRepairDetailsPanelState`).
class _RepairPiecesSection extends StatelessWidget {
  const _RepairPiecesSection({
    required this.checklist,
    required this.passQty,
    required this.repairQty,
    required this.currentPieceIndex,
    required this.pieceQtyControllers,
    required this.onSelectPiece,
    required this.onStep,
  });

  final List<QcRepairChecklistItemEntity> checklist;
  final int passQty;
  final int repairQty;
  final int currentPieceIndex;
  final List<Map<String, TextEditingController>> pieceQtyControllers;
  final ValueChanged<int> onSelectPiece;
  final void Function(String itemId, int delta) onStep;

  @override
  Widget build(BuildContext context) {
    final Map<String, TextEditingController> currentPieceControllers =
        currentPieceIndex < pieceQtyControllers.length
        ? pieceQtyControllers[currentPieceIndex]
        : const {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: AppDimensions.iconSm,
              color: AppColors.error,
            ),
            const SizedBox(width: AppDimensions.spacingXxs),
            Expanded(
              child: Text(
                'REPAIR PIECES TO INSPECT:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            _CountPill(
              label: '$passQty Passed',
              background: AppColors.successContainer,
              foreground: AppColors.success,
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            _CountPill(
              label: '$repairQty Repair',
              background: AppColors.errorContainer,
              foreground: AppColors.error,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Wrap(
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: [
            for (int i = 0; i < repairQty; i++)
              _PieceChip(
                index: i,
                selected: i == currentPieceIndex,
                visited: i < currentPieceIndex,
                onTap: () => onSelectPiece(i),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        if (currentPieceControllers.isNotEmpty)
          _RepairTable(
            checklist: checklist,
            qtyControllers: currentPieceControllers,
            onStep: onStep,
          ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// One "Piece #N" chip — tapping any chip (not just the current one) jumps
/// straight to that piece's qty table. [visited] (any piece already stepped
/// past via "Next") gets a highlighted background so it reads as distinct
/// from a piece not yet looked at, without overriding the [selected] style.
class _PieceChip extends StatelessWidget {
  const _PieceChip({
    required this.index,
    required this.selected,
    required this.visited,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final bool visited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? AppColors.textPrimary
        : visited
        ? AppColors.successContainer
        : AppColors.background;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.circle_outlined,
                size: 14,
                color: selected ? AppColors.onPrimary : AppColors.textHint,
              ),
              const SizedBox(width: AppDimensions.spacingXxs),
              Text(
                'Piece #${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.textPrimary,
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

/// Reactively styled off the controller's own value — no qty (the default)
/// reads as a plain, unselected chip; any qty > 0 flips it to an
/// error-tinted "this defect is flagged" chip, including a filled numbered
/// badge in place of the plain "(id)" prefix the previous design used.
/// A header row (ID / Repair / Qty) then one full-width row per defect,
/// instead of a 2-column chip grid. Always editable here (no locked/OK-mode
/// qty box variant), since this screen has separate OK and Submit Repair
/// Details buttons rather than one dialog that switches mode.
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

/// The "Pass Pieces" -/+ control — same overall shape as [_QtyStepper], but
/// with solid filled circular buttons instead of flat icon-only ones, so it
/// reads as visually distinct from the defect table's own steppers.
class _PassQtyStepper extends StatelessWidget {
  const _PassQtyStepper({required this.controller, required this.onStep});

  final TextEditingController controller;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.qcActionQtyStepperWidth,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
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
          _PassQtyStepperButton(
            icon: Icons.remove_rounded,
            onTap: () => onStep(-1),
          ),
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
          _PassQtyStepperButton(
            icon: Icons.add_rounded,
            onTap: () => onStep(1),
          ),
        ],
      ),
    );
  }
}

class _PassQtyStepperButton extends StatelessWidget {
  const _PassQtyStepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXs),
          child: Icon(icon, size: 16, color: AppColors.onPrimary),
        ),
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
