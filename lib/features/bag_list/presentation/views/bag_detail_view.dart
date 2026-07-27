import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/entities/bag_rm_summary_entity.dart';
import '../../domain/entities/diamond_detail_entity.dart';
import '../controllers/bag_detail_controller.dart';
import '../controllers/bag_timer_controller.dart';

/// Bag detail screen: a live productivity clock in the top bar, then Bag
/// Summary + the jewelry preview side by side (tablet) / stacked (phone),
/// and — full width, below that pair — Manufacturing Instructions and the
/// Diamond Details / Bag RM Summary tabs. Diamond Details / Bag RM Summary
/// render as a flex-column table that always fills the available width
/// exactly — no horizontal scrolling, on any phone or tablet size.
class BagDetailView extends GetView<BagDetailController> {
  const BagDetailView({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderRow(controller: controller),
                    const SizedBox(height: AppDimensions.spacingMd),
                    SectionCard(
                      title: AppStrings.manufacturingInstructions,
                      icon: Icons.build_outlined,
                      child: _ManufacturingSpecs(bag: controller.bag),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    SectionCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        child: Column(
                          children: [
                            _SegmentedTabBar(tabController: controller.tabController),
                            // Swaps the visible table directly off the tab index —
                            // switching only by tapping the segmented tab bar above,
                            // no left/right swipe gesture — while the section's
                            // height always matches exactly whichever table is
                            // currently selected.
                            AnimatedBuilder(
                              animation: controller.tabController,
                              builder: (context, _) {
                                return controller.tabController.index == 0
                                    ? _DiamondDetailsTable(details: controller.bag.diamondDetails)
                                    : _RmSummaryTable(items: controller.bag.rmSummary);
                              },
                            ),
                          ],
                        ),
                      ),
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

/// Bag Summary and the jewelry preview as a matched pair at the top — side
/// by side on tablet width, stacked on phone width. On tablet, the preview
/// is sized to exactly [_summaryHeight] x [_summaryHeight] — a true square
/// whose side equals the Bag Summary card's own (content-driven) height —
/// so the two always finish at the same bottom edge, with the image never
/// distorted into a tall or wide rectangle.
///
/// [_summaryHeight] is measured (not computed via [IntrinsicHeight], which
/// probes every descendant's intrinsic height and crashes given this card's
/// [Expanded]-based chip grid) by attaching a [GlobalKey] to the already
/// on-screen Bag Summary card and reading its real rendered size back after
/// each frame — the same measure-then-rebuild approach already used for
/// [_ExpandingTabBarView]'s dynamic tab height.
class _HeaderRow extends StatefulWidget {
  const _HeaderRow({required this.controller});

  final BagDetailController controller;

  @override
  State<_HeaderRow> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<_HeaderRow> {
  final GlobalKey _summaryKey = GlobalKey();
  double? _summaryHeight;

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double? height = _summaryKey.currentContext?.size?.height;
      if (height != null && height != _summaryHeight) {
        setState(() => _summaryHeight = height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasure();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;
        final Widget summary = KeyedSubtree(
          key: _summaryKey,
          child: _BagSummaryCard(bag: widget.controller.bag, columns: isTablet ? 3 : 1),
        );
        final Widget preview = _JewelryPreview(imageUrl: widget.controller.bag.imageUrl);

        if (!isTablet) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [summary, const SizedBox(height: AppDimensions.spacingMd), preview],
          );
        }

        // Fall back to the old fixed size for the one frame before the
        // real height has been measured.
        final double squareSide = _summaryHeight ?? AppDimensions.bagDetailSidebarWidth;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: summary),
            const SizedBox(width: AppDimensions.spacingMd),
            SizedBox(width: squareSide, height: squareSide, child: preview),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final BagDetailController controller;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        // Three-section layout — equal-flex Expanded on both sides of the
        // timer — keeps the timer pill dead-center in the toolbar no
        // matter how the leading (back button + bag no.) and trailing
        // (Done button) content widths differ from each other.
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TopBarButton(
                    icon: Icons.arrow_back_rounded,
                    label: AppStrings.backPause,
                    onTap: controller.pauseAndGoBack,
                    filled: false,
                  ),
                  const SizedBox(width: AppDimensions.spacingLg),
                  Text(
                    controller.bag.bagNo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            _LiveTimerPill(controller: controller),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _TopBarButton(
                  icon: Icons.check_rounded,
                  label: AppStrings.done,
                  onTap: controller.onDone,
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reads [BagTimerController] reactively so the top bar shows the same
/// running clock as [BagListItem] — a fresh "00:00:00, not running" state
/// if this bag's timer was never started.
class _LiveTimerPill extends StatelessWidget {
  const _LiveTimerPill({required this.controller});

  final BagDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final BagTimerController? timer = controller.timer;
      final bool isRunning = timer?.status.value == BagWorkStatus.running;
      final Duration elapsed = timer?.elapsed.value ?? Duration.zero;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isRunning ? AppColors.success : AppColors.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Text(
              DateTimeHelper.formatStopwatch(elapsed),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color background = filled ? AppColors.surface : AppColors.onPrimary.withValues(alpha: 0.16);
    final Color foreground = filled ? AppColors.primary : AppColors.onPrimary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: foreground),
              const SizedBox(width: AppDimensions.spacingXxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
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

/// Del Date / Part / Bag Qty / Pieces / Size / Customer / PoNo as a grid of
/// soft, color-coded icon-leading tiles (2 per row on tablet, 1 on phone).
/// Each tile's icon badge cycles through the app's semantic accent colors
/// (info/warning/success/primary) purely for visual variety — the colors
/// carry no status meaning here, unlike their use elsewhere in the app.
/// The card's height is left to size naturally to its content; see
/// [_HeaderRow], which stretches the jewelry preview to match it.
class _BagSummaryCard extends StatelessWidget {
  const _BagSummaryCard({required this.bag, required this.columns});

  final BagEntity bag;
  final int columns;

  static const List<Color> _accents = [
    AppColors.info,
    AppColors.warning,
    AppColors.success,
    AppColors.primary,
  ];
  static const List<Color> _accentContainers = [
    AppColors.infoContainer,
    AppColors.warningContainer,
    AppColors.successContainer,
    AppColors.primaryContainer,
  ];

  @override
  Widget build(BuildContext context) {
    final List<_SummaryFieldData> fields = [
      _SummaryFieldData(
        icon: Icons.event_outlined,
        label: AppStrings.delDate,
        value: bag.delDate == null ? '' : DateTimeHelper.formatDate(bag.delDate!),
      ),
      _SummaryFieldData(icon: Icons.inventory_2_outlined, label: AppStrings.bagQty, value: '${bag.bagQty}'),
      _SummaryFieldData(icon: Icons.style_outlined, label: AppStrings.styleNo, value: bag.styleNo ?? ''),
      _SummaryFieldData(icon: Icons.person_outline, label: AppStrings.customer, value: bag.customer ?? ''),
      _SummaryFieldData(icon: Icons.tag, label: AppStrings.part, value: bag.part ?? ''),
      _SummaryFieldData(icon: Icons.straighten_outlined, label: AppStrings.size, value: bag.size ?? ''),
    ];

    final List<Widget> items = [
      for (int i = 0; i < fields.length; i++)
        _SummaryDetailItem(
          icon: fields[i].icon,
          label: fields[i].label,
          value: fields[i].value,
          accent: _accents[i % _accents.length],
          accentContainer: _accentContainers[i % _accentContainers.length],
        ),
    ];

    final List<Widget> rows = [
      for (int i = 0; i < items.length; i += columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int c = 0; c < columns; c++) ...[
              if (c > 0) const SizedBox(width: AppDimensions.spacingSm),
              Expanded(child: i + c < items.length ? items[i + c] : const SizedBox()),
            ],
          ],
        ),
    ];

    return SectionCard(
      title: AppStrings.bagSummary,
      icon: Icons.summarize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimensions.spacingSm),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _SummaryFieldData {
  const _SummaryFieldData({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

class _SummaryDetailItem extends StatelessWidget {
  const _SummaryDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.accentContainer,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color accentContainer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, size: AppDimensions.iconSm, color: accent),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Metal / Design Gross Wt / Design Net Weight as a wrapped row of spec
/// chips, then the six instruction fields stacked one per line (always a
/// single column, on every screen size).
class _ManufacturingSpecs extends StatelessWidget {
  const _ManufacturingSpecs({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    final List<Widget> instructionTiles = [
      _InstructionTile(label: AppStrings.designInstr, value: bag.designInstr),
      _InstructionTile(label: AppStrings.custInstr, value: bag.custInstr),
      _InstructionTile(label: AppStrings.stampInstr, value: bag.stampInstr),
      _InstructionTile(label: AppStrings.rhodInstr, value: bag.rhodInstr),
      _InstructionTile(label: AppStrings.diamInstr, value: bag.diamInstr),
      _InstructionTile(label: AppStrings.sizeInstr, value: bag.sizeInstr),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SpecBox(
                icon: Icons.diamond_outlined,
                color: AppColors.primary,
                label: AppStrings.metal,
                value: bag.metal,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: _SpecBox(
                icon: Icons.scale_outlined,
                color: AppColors.info,
                label: AppStrings.designGrossWt,
                value: bag.designGrossWt == null ? null : '${bag.designGrossWt!.toStringAsFixed(2)} grm',
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: _SpecBox(
                icon: Icons.monitor_weight_outlined,
                color: AppColors.success,
                label: AppStrings.designNetWt,
                value: bag.designNetWt == null ? null : '${bag.designNetWt!.toStringAsFixed(2)} grm',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Column(
          children: [
            for (final tile in instructionTiles) ...[
              tile,
              if (tile != instructionTiles.last) const SizedBox(height: AppDimensions.spacingSm),
            ],
          ],
        ),
      ],
    );
  }
}

class _SpecBox extends StatelessWidget {
  const _SpecBox({required this.icon, required this.color, required this.label, required this.value});

  final IconData icon;
  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.iconMd,
            height: AppDimensions.iconMd,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: AppDimensions.iconSm, color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.4),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(
                  value ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionTile extends StatelessWidget {
  const _InstructionTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(label, style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Text(
              value ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        child: SizedBox(
          height: AppDimensions.bagDetailSegmentedTabBarHeight,
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppColors.onPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: AppStrings.diamondDetails),
              Tab(text: AppStrings.bagRmSummary),
            ],
          ),
        ),
      ),
    );
  }
}

/// One column definition for [_FlexTable]: [flex] controls its share of the
/// table's total width (so the table always fills exactly 100% of
/// whatever width it's given — tablet or phone — with no fixed pixel
/// widths and no horizontal scrolling).
class _FlexColumn {
  const _FlexColumn({required this.label, this.flex = 2, this.alignEnd = false});

  final String label;
  final int flex;
  final bool alignEnd;
}

/// A table that always fits the width it's laid out in. Each cell is
/// wrapped in [FittedBox] so a value that's still too long for its column
/// on a narrow phone scales down instead of overflowing or forcing a
/// horizontal scrollbar.
class _FlexTable extends StatelessWidget {
  const _FlexTable({required this.columns, required this.rows, required this.isEmpty});

  final List<_FlexColumn> columns;
  final List<List<String>> rows;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoredBox(
                color: AppColors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingSm,
                  ),
                  child: Row(
                    children: [
                      for (final column in columns)
                        Expanded(
                          flex: column.flex,
                          child: _FlexCell(
                            text: column.label.toUpperCase(),
                            alignEnd: column.alignEnd,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: Text(
                    AppStrings.noDataAvailable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  ),
                )
              else
                for (int r = 0; r < rows.length; r++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: r.isEven ? AppColors.surface : AppColors.background,
                      border: const Border(top: BorderSide(color: AppColors.divider)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingSm,
                      ),
                      child: Row(
                        children: [
                          for (int c = 0; c < columns.length; c++)
                            Expanded(
                              flex: columns[c].flex,
                              child: _FlexCell(text: rows[r][c], alignEnd: columns[c].alignEnd),
                            ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlexCell extends StatelessWidget {
  const _FlexCell({required this.text, required this.alignEnd, this.style});

  final String text;
  final bool alignEnd;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _DiamondDetailsTable extends StatelessWidget {
  const _DiamondDetailsTable({required this.details});

  final List<DiamondDetailEntity> details;

  @override
  Widget build(BuildContext context) {
    return _FlexTable(
      isEmpty: details.isEmpty,
      columns: const [
        _FlexColumn(label: AppStrings.srNo, flex: 2),
        _FlexColumn(label: AppStrings.shape, flex: 3),
        _FlexColumn(label: AppStrings.sizeMm, flex: 3, alignEnd: true),
        _FlexColumn(label: AppStrings.pcs, flex: 2, alignEnd: true),
        _FlexColumn(label: AppStrings.weightCt, flex: 3, alignEnd: true),
        _FlexColumn(label: AppStrings.color, flex: 2),
        _FlexColumn(label: AppStrings.clarity, flex: 2),
        _FlexColumn(label: AppStrings.setting, flex: 3),
      ],
      rows: [
        for (final d in details)
          [
            '${d.srNo}',
            d.shape,
            d.sizeMm.toStringAsFixed(2),
            '${d.pcs}',
            d.weightCt.toStringAsFixed(2),
            d.color,
            d.clarity,
            d.setting,
          ],
      ],
    );
  }
}

class _RmSummaryTable extends StatelessWidget {
  const _RmSummaryTable({required this.items});

  final List<BagRmSummaryEntity> items;

  @override
  Widget build(BuildContext context) {
    return _FlexTable(
      isEmpty: items.isEmpty,
      columns: const [
        _FlexColumn(label: AppStrings.materialCode, flex: 3),
        _FlexColumn(label: AppStrings.rmDescription, flex: 4),
        _FlexColumn(label: AppStrings.allocatedQty, flex: 3, alignEnd: true),
        _FlexColumn(label: AppStrings.issuedQty, flex: 3, alignEnd: true),
        _FlexColumn(label: AppStrings.status, flex: 2, alignEnd: true),
      ],
      rows: [
        for (final r in items) [r.materialCode, r.description, r.allocatedQty, r.issuedQty, r.status],
      ],
    );
  }
}

/// The jewelry preview — its own hero card so it stays visible no matter
/// which tab is selected below it. Always a true square ([AspectRatio] of
/// 1) — on tablet its width is fixed to [AppDimensions.bagDetailSidebarWidth]
/// (see [_HeaderRow]), so the square's side is exactly that; on phone it's
/// stretched to the full column width, so the square's side is the screen
/// width. The image itself is `cover`-fit so it never distorts.
class _JewelryPreview extends StatelessWidget {
  const _JewelryPreview({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: imageUrl == null
              ? const ColoredBox(
                  color: AppColors.surfaceVariant,
                  child: Center(
                    child: Icon(Icons.diamond_outlined, color: AppColors.textHint, size: AppDimensions.iconXl),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: AppColors.surfaceVariant,
                    child: Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
                  ),
                ),
        ),
      ),
    );
  }
}
