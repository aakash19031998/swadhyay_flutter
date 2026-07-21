import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_card.dart';
import '../controllers/bag_detail_controller.dart';

/// Bag detail screen: manufacturing instruction grid, a Diamond
/// Details / BagRmSummary tab pair (static placeholder tables for now — a
/// real dynamic table lands later), a jewelry preview, and a right-hand
/// summary sidebar. Laid out primarily for tablet width; narrow screens
/// stack the sidebar below the main content instead of beside it.
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                controller.bag.bagNo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _TopBarButton(
                icon: Icons.arrow_back_rounded,
                label: AppStrings.backPause,
                onTap: controller.pauseAndGoBack,
                filled: false,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _TopBarButton(
                icon: Icons.check_rounded,
                label: AppStrings.done,
                onTap: controller.onDone,
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionCard(
          title: AppStrings.manufacturingInstructions,
          icon: Icons.build_outlined,
          padding: EdgeInsets.zero,
          child: _InfoGrid(),
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
                    children: const [
                      _PlaceholderTableTab(
                        columns: ['Sr No', 'Shape', 'Size (MM)', 'Pcs', 'Wt (ct)', 'Color', 'Clarity', 'Setting'],
                      ),
                      _PlaceholderTableTab(
                        columns: ['Sr No', 'Material', 'Gross Wt', 'Stone Wt', 'Net Metal Wt', 'Qty'],
                      ),
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

class _InfoGrid extends StatelessWidget {
  const _InfoGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GridRow(cells: const [
          _GridCellData(AppStrings.metal, 1),
          _GridCellData(AppStrings.designGrossWt, 1),
          _GridCellData(AppStrings.extra, 1),
        ]),
        _GridRow(cells: const [
          _GridCellData(AppStrings.diamondWax, 2),
          _GridCellData(AppStrings.extra2, 1),
        ]),
        const _GridRow(cells: [_GridCellData(AppStrings.designInstr, 3)]),
        const _GridRow(cells: [_GridCellData(AppStrings.custInstr, 3)]),
        const _GridRow(cells: [_GridCellData(AppStrings.stampInstr, 3)]),
        const _GridRow(cells: [_GridCellData(AppStrings.rhodInstr, 3)]),
        const _GridRow(cells: [_GridCellData(AppStrings.diamInstr, 3)]),
        _GridRow(cells: const [_GridCellData(AppStrings.sizeInstr, 3)], isLast: true),
      ],
    );
  }
}

class _GridCellData {
  const _GridCellData(this.label, this.flex);

  final String label;
  final int flex;
}

class _GridRow extends StatelessWidget {
  const _GridRow({required this.cells, this.isLast = false});

  final List<_GridCellData> cells;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cells.length; i++)
            Expanded(
              flex: cells[i].flex,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: i == cells.length - 1
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Text(
                  '${cells[i].label} :',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Static stand-in for the dynamic table that will replace it once the
/// backend contract for this tab is defined.
class _PlaceholderTableTab extends StatelessWidget {
  const _PlaceholderTableTab({required this.columns});

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
              columns: [for (final c in columns) DataColumn(label: Text(c))],
              rows: const [],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            AppStrings.noDataAvailable,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
          ),
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
    return Column(
      children: [
        SectionCard(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          child: _JewelryPreview(imageUrl: controller.bag.imageUrl),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        SectionCard(
          title: AppStrings.bagSummary,
          icon: Icons.summarize_outlined,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
          child: Column(
            children: [
              const _SidebarField(icon: Icons.event_outlined, label: AppStrings.delDate, value: ''),
              const _SidebarField(icon: Icons.tag, label: '/ part', value: ''),
              _SidebarField(
                icon: Icons.inventory_2_outlined,
                label: AppStrings.bagQty,
                value: '${controller.bag.bagQty}',
              ),
              const _SidebarField(icon: Icons.numbers_outlined, label: '(qty)', value: ''),
              const _SidebarField(icon: Icons.straighten_outlined, label: AppStrings.size, value: ''),
              const _SidebarField(icon: Icons.person_outline, label: AppStrings.customer, value: ''),
              const _SidebarField(
                icon: Icons.receipt_long_outlined,
                label: AppStrings.poNo,
                value: '',
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
