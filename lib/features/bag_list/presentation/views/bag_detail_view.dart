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

/// Bag detail screen: a live productivity clock in the top bar, a
/// manufacturing-instructions spec grid, a Diamond Details / Bag RM Summary
/// tab pair, a jewelry preview, and a right-hand summary sidebar. Laid out
/// primarily for tablet width; narrow screens stack the sidebar below the
/// main content instead of beside it.
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

                    final Widget main = _MainContent(controller: controller);
                    final Widget sidebar = _Sidebar(controller: controller);

                    if (!isTablet) {
                      return Column(
                        children: [main, const SizedBox(height: AppDimensions.spacingMd), sidebar],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: main),
                        const SizedBox(width: AppDimensions.spacingMd),
                        SizedBox(width: AppDimensions.bagDetailSidebarWidth, child: sidebar),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
                  const SizedBox(width: AppDimensions.spacingSm),
                  Text(
                    controller.bag.bagNo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          vertical: AppDimensions.spacingXs,
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isRunning ? AppColors.success : AppColors.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Text(
              DateTimeHelper.formatStopwatch(elapsed),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
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

class _MainContent extends StatelessWidget {
  const _MainContent({required this.controller});

  final BagDetailController controller;

  @override
  Widget build(BuildContext context) {
    final BagEntity bag = controller.bag;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: AppStrings.manufacturingInstructions,
          icon: Icons.build_outlined,
          child: _ManufacturingSpecs(bag: bag),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        SectionCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Column(
              children: [
                _SegmentedTabBar(tabController: controller.tabController),
                SizedBox(
                  height: AppDimensions.bagDetailTabViewHeight,
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      _DiamondDetailsTable(details: bag.diamondDetails),
                      _RmSummaryTable(items: bag.rmSummary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Metal / Design Gross Wt / Extra / Diamond (Wax) / Extra2 as a wrapped
/// row of spec chips, then the six longer instruction fields as a
/// responsive 2-column (tablet) / 1-column (phone) grid — replacing the
/// old label-only bordered table with real values.
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
        Wrap(
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: [
            _SpecBox(label: AppStrings.metal, value: bag.metal),
            _SpecBox(
              label: AppStrings.designGrossWt,
              value: bag.designGrossWt == null ? null : '${bag.designGrossWt!.toStringAsFixed(2)} grm',
            ),
            _SpecBox(label: AppStrings.diamondWax, value: bag.diamondWax),
            _SpecBox(label: AppStrings.extra, value: bag.extra),
            _SpecBox(label: AppStrings.extra2, value: bag.extra2),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

            if (!isTablet) {
              return Column(
                children: [
                  for (final tile in instructionTiles) ...[
                    tile,
                    if (tile != instructionTiles.last) const SizedBox(height: AppDimensions.spacingSm),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (int i = 0; i < instructionTiles.length; i += 2) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: instructionTiles[i]),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(child: instructionTiles[i + 1]),
                      ],
                    ),
                  ),
                  if (i + 2 < instructionTiles.length) const SizedBox(height: AppDimensions.spacingSm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SpecBox extends StatelessWidget {
  const _SpecBox({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.4),
          ),
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            value ?? '—',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
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

class _DiamondDetailsTable extends StatelessWidget {
  const _DiamondDetailsTable({required this.details});

  final List<DiamondDetailEntity> details;

  @override
  Widget build(BuildContext context) {
    return _DataTableTab(
      isEmpty: details.isEmpty,
      table: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
        columns: const [
          DataColumn(label: Text(AppStrings.srNo)),
          DataColumn(label: Text(AppStrings.shape)),
          DataColumn(label: Text(AppStrings.sizeMm)),
          DataColumn(label: Text(AppStrings.pcs)),
          DataColumn(label: Text(AppStrings.weightCt)),
          DataColumn(label: Text(AppStrings.color)),
          DataColumn(label: Text(AppStrings.clarity)),
          DataColumn(label: Text(AppStrings.setting)),
        ],
        rows: [
          for (final d in details)
            DataRow(cells: [
              DataCell(Text('${d.srNo}')),
              DataCell(Text(d.shape)),
              DataCell(Text(d.sizeMm.toStringAsFixed(2))),
              DataCell(Text('${d.pcs}')),
              DataCell(Text(d.weightCt.toStringAsFixed(2))),
              DataCell(Text(d.color)),
              DataCell(Text(d.clarity)),
              DataCell(Text(d.setting)),
            ]),
        ],
      ),
    );
  }
}

class _RmSummaryTable extends StatelessWidget {
  const _RmSummaryTable({required this.items});

  final List<BagRmSummaryEntity> items;

  @override
  Widget build(BuildContext context) {
    return _DataTableTab(
      isEmpty: items.isEmpty,
      table: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
        columns: const [
          DataColumn(label: Text(AppStrings.materialCode)),
          DataColumn(label: Text(AppStrings.rmDescription)),
          DataColumn(label: Text(AppStrings.allocatedQty)),
          DataColumn(label: Text(AppStrings.issuedQty)),
          DataColumn(label: Text(AppStrings.status)),
        ],
        rows: [
          for (final r in items)
            DataRow(cells: [
              DataCell(Text(r.materialCode)),
              DataCell(Text(r.description)),
              DataCell(Text(r.allocatedQty)),
              DataCell(Text(r.issuedQty)),
              DataCell(
                Text(
                  r.status,
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800),
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

class _DataTableTab extends StatelessWidget {
  const _DataTableTab({required this.table, required this.isEmpty});

  final DataTable table;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
          if (isEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              AppStrings.noDataAvailable,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.controller});

  final BagDetailController controller;

  @override
  Widget build(BuildContext context) {
    final BagEntity bag = controller.bag;

    return Column(
      children: [
        SectionCard(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          child: _JewelryPreview(imageUrl: bag.imageUrl),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        SectionCard(
          title: AppStrings.bagSummary,
          icon: Icons.summarize_outlined,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
          child: Column(
            children: [
              _SidebarField(
                icon: Icons.event_outlined,
                label: AppStrings.delDate,
                value: bag.delDate == null ? '' : DateTimeHelper.formatDate(bag.delDate!),
              ),
              _SidebarField(icon: Icons.tag, label: AppStrings.part, value: bag.part ?? ''),
              _SidebarField(
                icon: Icons.inventory_2_outlined,
                label: AppStrings.bagQty,
                value: '${bag.bagQty}',
              ),
              _SidebarField(
                icon: Icons.numbers_outlined,
                label: AppStrings.pieces,
                value: bag.pieceQty == null ? '' : '${bag.pieceQty}',
              ),
              _SidebarField(icon: Icons.straighten_outlined, label: AppStrings.size, value: bag.size ?? ''),
              _SidebarField(icon: Icons.person_outline, label: AppStrings.customer, value: bag.customer ?? ''),
              _SidebarField(
                icon: Icons.receipt_long_outlined,
                label: AppStrings.poNo,
                value: bag.poNo ?? '',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The jewelry preview lives here — on its own hero card in the sidebar —
/// rather than inside the Diamond Details tab, so it stays visible no
/// matter which tab is selected.
class _JewelryPreview extends StatelessWidget {
  const _JewelryPreview({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: imageUrl == null
            ? const ColoredBox(
                color: AppColors.surfaceVariant,
                child: Icon(Icons.diamond_outlined, color: AppColors.textHint, size: AppDimensions.iconXl),
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
    );
  }
}

class _SidebarField extends StatelessWidget {
  const _SidebarField({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimensions.iconSm, color: AppColors.textSecondary),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                  Text(
                    value.isEmpty ? '—' : value,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
