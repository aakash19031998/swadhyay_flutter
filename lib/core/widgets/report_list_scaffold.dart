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
  });

  final bool isLoading;
  final String? errorMessage;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchChanged;
  final String? emptyMessage;
  final String? searchHint;

  /// When provided, renders a [GridView] (e.g. Design Image thumbnails)
  /// instead of a [ListView].
  final SliverGridDelegate? gridDelegate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: AppSearchField(onChanged: onSearchChanged, hint: searchHint ?? 'Search'),
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

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: gridDelegate == null
          ? ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spacingSm),
              itemBuilder: (context, index) => itemBuilder(context, items[index]),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              gridDelegate: gridDelegate!,
              itemCount: items.length,
              itemBuilder: (context, index) => itemBuilder(context, items[index]),
            ),
    );
  }
}
