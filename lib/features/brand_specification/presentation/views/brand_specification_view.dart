import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/gradient_top_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/brand_specification_entity.dart';
import '../controllers/brand_specification_controller.dart';

/// Brand Specification: a persistent brand list on the left (tapping a
/// brand loads its rows immediately — no dropdown, no separate Show step),
/// with the selected brand's specification table on the right.
class BrandSpecificationView extends GetView<BrandSpecificationController> {
  const BrandSpecificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // The sidebar + table below are a fixed, non-scrolling `Row`, not a
      // `SingleChildScrollView` — see `_SpecTable`'s `ListView.builder` for
      // why (lazy row building needs bounded height). `false` keeps the
      // keyboard from ever squeezing that fixed layout into less height
      // than it needs; only the table area reserves space for it instead
      // (see its `MediaQuery.viewInsets.bottom` padding below).
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const GradientTopBar(title: AppStrings.brandSpecification),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BrandSidebar(controller: controller),
                  const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                  Expanded(child: _MainContent(controller: controller)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Persistent brand list — replaces the dropdown + Show button. Tapping a
/// brand calls [BrandSpecificationController.selectBrand], which loads its
/// rows right away.
class _BrandSidebar extends StatelessWidget {
  const _BrandSidebar({required this.controller});

  final BrandSpecificationController controller;

  static const double _width = 260;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: ColoredBox(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: Text(
                AppStrings.selectBrand.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingBrands.value) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                final List<BrandEntity> brands = controller.brands;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm),
                  itemCount: brands.length,
                  itemBuilder: (context, i) {
                    final BrandEntity brand = brands[i];
                    return Obx(() {
                      final bool selected = controller.selectedBrand.value?.id == brand.id;
                      return _BrandTile(
                        label: brand.name,
                        selected: selected,
                        onTap: () => controller.selectBrand(brand),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxs),
      child: Material(
        color: selected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingMd,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right-hand pane: selected brand name + "Showing X of Y" + search in one
/// header row, then the results table beneath it — matches the reference
/// design's flat, card-less layout instead of the previous `SectionCard`s.
class _MainContent extends StatelessWidget {
  const _MainContent({required this.controller});

  final BrandSpecificationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final BrandEntity? brand = controller.selectedBrand.value;
      if (brand == null) {
        return const _EmptyState(
          message: AppStrings.selectBrandFromList,
          icon: Icons.storefront_outlined,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

                final Widget heading = Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                );

                final Widget countText = Obx(
                  () => Text.rich(
                    TextSpan(
                      text: 'Showing: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: '${controller.filteredItems.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const TextSpan(text: ' of '),
                        TextSpan(
                          text: '${controller.items.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const TextSpan(text: ' records'),
                      ],
                    ),
                  ),
                );

                final Widget searchField = Obx(() {
                  final bool hasText = controller.searchQuery.value.isNotEmpty;
                  return TextField(
                    controller: controller.searchController,
                    enabled: controller.hasSearched.value,
                    onChanged: controller.onSearchChanged,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: AppStrings.searchSpecificationsHint,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: AppDimensions.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: !hasText
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: AppDimensions.iconSm),
                              onPressed: () {
                                controller.searchController.clear();
                                controller.onSearchChanged('');
                              },
                            ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  );
                });

                if (isTablet) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: heading),
                      const SizedBox(width: AppDimensions.spacingMd),
                      countText,
                      const SizedBox(width: AppDimensions.spacingMd),
                      SizedBox(width: 260, child: searchField),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    const SizedBox(height: AppDimensions.spacingSm),
                    countText,
                    const SizedBox(height: AppDimensions.spacingSm),
                    searchField,
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const HkLoaderCard();
              if (controller.errorMessage.value != null) {
                return AppErrorWidget(message: controller.errorMessage.value!, onRetry: controller.show);
              }

              final List<BrandSpecificationEntity> filtered = controller.filteredItems;
              final bool hasRawItems = controller.items.isNotEmpty;
              if (filtered.isEmpty) {
                return _EmptyState(
                  message: hasRawItems ? AppStrings.noMatchingSpecifications : AppStrings.noDataFound,
                  icon: Icons.search_off_rounded,
                );
              }

              final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
              return Padding(
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: _SpecTable(rows: filtered, controller: controller),
              );
            }),
          ),
        ],
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.iconLg, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flat table matching the reference design — plain header (no gradient/tint
/// fill, just a bottom border), left-aligned wrapping text cells, and a
/// genuinely lazy `ListView.builder` for the rows (only visible rows built),
/// same reasoning as before: a brand can return 1000+ rows.
class _SpecTable extends StatelessWidget {
  const _SpecTable({required this.rows, required this.controller});

  final List<BrandSpecificationEntity> rows;
  final BrandSpecificationController controller;

  /// Fixed width reserved for the trailing PDF icon on every row — the
  /// header reserves the same blank width so columns still line up.
  static const double _trailingWidth = 28;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _GutteredRow(
                    children: const [
                      _HeaderCell(AppStrings.productId),
                      _HeaderCell(AppStrings.specHkStyle),
                      _HeaderCell(AppStrings.custMaterial),
                      _HeaderCell(AppStrings.specStyleKt),
                      _HeaderCell(AppStrings.specStyleCol),
                      _HeaderCell(AppStrings.specCustomer),
                      _HeaderCell(AppStrings.shortCode),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                const SizedBox(width: _trailingWidth),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, r) => _SpecRow(
              item: rows[r],
              controller: controller,
              trailingWidth: _trailingWidth,
            ),
          ),
        ),
      ],
    );
  }
}

/// A `Row` with an [AppDimensions.spacingSm] gutter inserted between every
/// child.
class _GutteredRow extends StatelessWidget {
  const _GutteredRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.spacingSm),
          children[i],
        ],
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.item, required this.controller, required this.trailingWidth});

  final BrandSpecificationEntity item;
  final BrandSpecificationController controller;
  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Material(
        color: AppColors.surface,
        child: InkWell(
          onTap: () => controller.viewSpecificationPdf(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _GutteredRow(
                    children: [
                      _Cell(
                        child: Text(
                          item.productId,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      _Cell(
                        child: Text(
                          item.specHkStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _Cell(
                        child: Text(
                          item.custMaterial,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _Cell(
                        child: _Tag(
                          label: item.specStyleKt,
                          background: AppColors.warningContainer,
                          foreground: AppColors.warning,
                        ),
                      ),
                      _Cell(
                        child: _Tag(
                          label: item.specStyleCol,
                          background: AppColors.surfaceVariant,
                          foreground: AppColors.textSecondary,
                        ),
                      ),
                      _Cell(
                        child: Text(
                          item.specCustomer,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _Cell(
                        child: _Tag(
                          label: item.shortCode,
                          background: AppColors.surfaceVariant,
                          foreground: AppColors.textPrimary,
                          monospace: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                SizedBox(
                  width: trailingWidth,
                  child: const Center(
                    child: Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One data cell: left-aligned, wraps up to two lines instead of shrinking
/// to fit on one — matches the reference design's readable, wrapped text
/// look (e.g. "SI Clarity Solitaire").
class _Cell extends StatelessWidget {
  const _Cell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
    this.monospace = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXxs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimensions.radiusPill)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontFamily: monospace ? 'monospace' : null,
            ),
      ),
    );
  }
}
