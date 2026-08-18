import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_modern_dropdown.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/brand_specification_entity.dart';
import '../controllers/brand_specification_controller.dart';

/// Brand Specification: pick a brand, tap Show, then read/search its
/// specification rows. The brand field reuses [AppModernDropdown] — the
/// same dropdown Bag Completion's "Done" screen uses for Work Type — and
/// the results table's chrome (bordered box, `primaryContainer` header,
/// zebra rows) mirrors the shared `FlexTable` used by that same screen's
/// Bag/RM Summary table, so this screen reads as part of the same family
/// instead of a one-off design.
class BrandSpecificationView extends GetView<BrandSpecificationController> {
  const BrandSpecificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterCard(controller: controller),
                    // Nothing below the filter renders at all until Show has
                    // actually been tapped — no empty-state placeholder card,
                    // just the filter alone — so this reads as "pick a
                    // brand" rather than a results screen with a message in
                    // it.
                    Obx(() {
                      final bool showBody =
                          controller.isLoading.value || controller.errorMessage.value != null || controller.hasSearched.value;
                      if (!showBody) return const SizedBox.shrink();

                      final Widget body;
                      if (controller.isLoading.value) {
                        body = const HkLoaderCard();
                      } else if (controller.errorMessage.value != null) {
                        body = AppErrorWidget(
                          message: controller.errorMessage.value!,
                          onRetry: controller.show,
                        );
                      } else {
                        body = _ResultsCard(controller: controller);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
                        child: body,
                      );
                    }),
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

class _TopBar extends StatelessWidget {
  const _TopBar();

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
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
              onPressed: Get.back,
            ),
            Text(
              AppStrings.brandSpecification,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand dropdown + Show button, styled exactly like Bag Completion's
/// "Add Dummy Work Entry" section: a [SectionCard] (colored icon badge +
/// title) wrapping an [AppModernDropdown] — the same field Work Type uses.
class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.controller});

  final BrandSpecificationController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.filterSectionTitle,
      icon: Icons.filter_alt_outlined,
      accentColor: AppColors.info,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
      ),
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AppModernDropdown<BrandEntity>(
                label: controller.isLoadingBrands.value ? AppStrings.loading : AppStrings.brandNameLabel,
                icon: Icons.storefront_outlined,
                value: controller.selectedBrand.value,
                items: controller.brands,
                itemLabel: (brand) => brand.name,
                onChanged: controller.isLoadingBrands.value ? null : controller.onBrandChanged,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            AppButton(
              label: AppStrings.show,
              icon: Icons.filter_alt_outlined,
              fullWidth: false,
              isLoading: controller.isLoading.value,
              onPressed: controller.selectedBrand.value != null ? controller.show : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Results: a colored "Showing X of Y" badge + search field toolbar, over
/// the `FlexTable`-styled results table — same composition as Bag
/// Completion's Pending/Completed Work [SectionCard]s.
class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.controller});

  final BrandSpecificationController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: AppStrings.specificationsSectionTitle,
      icon: Icons.diamond_outlined,
      accentColor: AppColors.primary,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

                final Widget countBadge = Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSm,
                      vertical: AppDimensions.spacingXxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.table_rows_rounded, size: 14, color: AppColors.success),
                        const SizedBox(width: AppDimensions.spacingXxs),
                        Text(
                          '${controller.filteredItems.length} of ${controller.items.length} records',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                );

                final Widget searchField = Obx(
                  () => TextField(
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
                      suffixIcon: controller.searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: AppDimensions.iconSm),
                              onPressed: () {
                                controller.searchController.clear();
                                controller.onSearchChanged('');
                              },
                            ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                );

                if (isTablet) {
                  return Row(
                    children: [
                      countBadge,
                      const SizedBox(width: AppDimensions.spacingMd),
                      Expanded(child: searchField),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    countBadge,
                    const SizedBox(height: AppDimensions.spacingSm),
                    searchField,
                  ],
                );
              },
            ),
          ),
          Obx(() {
            // This card only ever builds after `show()` has run (see the
            // gate in `BrandSpecificationView`), so `items` here always
            // reflects a completed search — an empty result means either no
            // rows for the brand or the live search filtered them all out.
            final List<BrandSpecificationEntity> filtered = controller.filteredItems;
            final bool hasRawItems = controller.items.isNotEmpty;

            if (filtered.isEmpty) {
              return _EmptyState(
                message: hasRawItems ? AppStrings.noMatchingSpecifications : AppStrings.noDataFound,
                icon: Icons.search_off_rounded,
              );
            }
            return _SpecTable(rows: filtered, controller: controller);
          }),
        ],
      ),
    );
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

/// Mirrors the shared `FlexTable`'s chrome exactly — `Padding(spacingMd)` +
/// bordered `ClipRRect` box (`AppColors.primary` at 18% alpha),
/// `primaryContainer` header, zebra-striped `surface`/`background` rows,
/// `divider`-colored row borders — the same widget Bag Completion's
/// Pending/Completed Work tables and Bag Detail's Diamond Details/Bag RM
/// Summary tables use. Built by hand (not the `FlexTable` widget itself)
/// because `FlexTable` only renders plain text cells, and this table needs
/// rich per-column cells (color tags, a monospace badge, a tap-to-open PDF
/// indicator).
class _SpecTable extends StatelessWidget {
  const _SpecTable({required this.rows, required this.controller});

  final List<BrandSpecificationEntity> rows;
  final BrandSpecificationController controller;

  /// Fixed width reserved for the trailing PDF icon/spinner on every row —
  /// the header reserves the same blank width so columns still line up,
  /// same convention as `FlexTable`'s own `rowTrailing`.
  static const double _trailingWidth = 28;

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
                  child: const Row(
                    children: [
                      Expanded(
                        child: _GutteredRow(
                          children: [
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
                      SizedBox(width: AppDimensions.spacingXs),
                      SizedBox(width: _trailingWidth),
                    ],
                  ),
                ),
              ),
              for (int r = 0; r < rows.length; r++)
                _SpecRow(item: rows[r], isEven: r.isEven, controller: controller, trailingWidth: _trailingWidth),
            ],
          ),
        ),
      ),
    );
  }
}

/// A `Row` with an [AppDimensions.spacingSm] gutter inserted between every
/// child — same gutter [FlexTable] uses between its columns.
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
      child: Align(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.item,
    required this.isEven,
    required this.controller,
    required this.trailingWidth,
  });

  final BrandSpecificationEntity item;
  final bool isEven;
  final BrandSpecificationController controller;
  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isEven ? AppColors.surface : AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => controller.viewSpecificationPdf(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      _Cell(child: Text(item.specHkStyle, style: Theme.of(context).textTheme.bodyMedium)),
                      _Cell(child: Text(item.custMaterial, style: Theme.of(context).textTheme.bodyMedium)),
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
                          swatch: _swatchFor(item.specStyleCol),
                        ),
                      ),
                      _Cell(child: Text(item.specCustomer, style: Theme.of(context).textTheme.bodyMedium)),
                      _Cell(
                        child: _Tag(
                          label: item.shortCode,
                          background: AppColors.infoContainer,
                          foreground: AppColors.info,
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

  /// A small color swatch for the actual gold/metal tone a spec names
  /// (Yellow/White/Rose/Platinum) — a literal material color, not a UI
  /// token, so it's kept local to this cell rather than added to
  /// [AppColors].
  static Color? _swatchFor(String colorName) {
    final String c = colorName.toLowerCase();
    if (c.contains('yellow')) return const Color(0xFFE8C547);
    if (c.contains('rose')) return const Color(0xFFE3AFAE);
    if (c.contains('white')) return const Color(0xFFD6D8E0);
    if (c.contains('platinum') || c.contains('pt')) return const Color(0xFFC6C8D2);
    return null;
  }
}

/// One data cell: centered, [FittedBox]-shrunk so a value too wide for its
/// equally-divided column on a narrow phone scales down instead of
/// overflowing — same technique as [FlexTable]'s `FlexCell`.
class _Cell extends StatelessWidget {
  const _Cell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
    this.swatch,
    this.monospace = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? swatch;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXxs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimensions.radiusPill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swatch != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppDimensions.spacingXxs),
          ],
          Text(
            label,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontFamily: monospace ? 'monospace' : null,
                ),
          ),
        ],
      ),
    );
  }
}
