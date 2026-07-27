import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import 'app_empty_widget.dart';
import 'app_error_widget.dart';
import 'app_loader.dart';
import 'app_search_field.dart';

/// Shared body for every search + list/report screen: search field up top,
/// then loading / error / empty / data states below, wrapped in a
/// [RefreshIndicator]. Callers pass a plain snapshot of their controller's
/// state and wrap the call site in `Obx` so it rebuilds reactively.
class ReportListScaffold<T> extends StatelessWidget {
  const ReportListScaffold({
    required this.isLoading,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onSearchChanged,
    super.key,
    this.errorMessage,
    this.emptyMessage,
    this.searchHint,
    this.gridDelegate,
    this.masonryColumnCount,
    this.searchBarTrailing,
    this.searchController,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchChanged;
  final String? emptyMessage;
  final String? searchHint;

  /// An optional widget (e.g. a scan button) placed to the right of the
  /// search field. Only the screens that pass one get it — every other
  /// caller's search bar is unchanged.
  final Widget? searchBarTrailing;

  /// Optional external controller for the search field — e.g. so a scanned
  /// barcode/QR value can be shown in the field itself, not just applied as
  /// a silent filter. Omitted by every caller except Bag List.
  final TextEditingController? searchController;

  /// When provided, renders a [GridView] (e.g. Design Image thumbnails) —
  /// every tile is forced to the same fixed size, which fits square/near-
  /// square media but clips a card whose content can grow taller than that.
  final SliverGridDelegate? gridDelegate;

  /// When provided (and [gridDelegate] is not), lays items out in this many
  /// side-by-side columns with each column an independently-sized
  /// [Column] — so every item keeps its own natural, content-driven height
  /// (never clipped, never needs a hand-tuned fixed extent) instead of a
  /// [GridView]'s uniform row height.
  final int? masonryColumnCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: searchBarTrailing == null
              ? AppSearchField(onChanged: onSearchChanged, hint: searchHint ?? 'Search', controller: searchController)
              : Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        onChanged: onSearchChanged,
                        hint: searchHint ?? 'Search',
                        controller: searchController,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    searchBarTrailing!,
                  ],
                ),
        ),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading && items.isEmpty) return const AppLoader();
    if (errorMessage != null && items.isEmpty) {
      return AppErrorWidget(message: errorMessage!, onRetry: onRefresh);
    }
    if (items.isEmpty) return AppEmptyWidget(message: emptyMessage ?? 'No data found');

    if (gridDelegate != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          gridDelegate: gridDelegate!,
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        ),
      );
    }

    if (masonryColumnCount != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: _MasonryList(
          columnCount: masonryColumnCount!,
          items: items,
          itemBuilder: itemBuilder,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spacingSm),
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }
}

/// Distributes [items] round-robin across [columnCount] independent
/// [Column]s inside one scroll view, so each item's height comes purely
/// from its own content — no shared row height, no clipping.
class _MasonryList<T> extends StatelessWidget {
  const _MasonryList({
    required this.columnCount,
    required this.items,
    required this.itemBuilder,
  });

  final int columnCount;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final List<List<T>> columns = List.generate(columnCount, (_) => <T>[]);
    for (int i = 0; i < items.length; i++) {
      columns[i % columnCount].add(items[i]);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int c = 0; c < columnCount; c++) ...[
            if (c > 0) const SizedBox(width: AppDimensions.spacingLg),
            Expanded(
              child: Column(
                children: [
                  for (final item in columns[c]) ...[
                    itemBuilder(context, item),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
