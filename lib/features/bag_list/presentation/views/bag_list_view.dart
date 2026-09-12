import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../../../../core/widgets/scan_button.dart';
import '../../domain/entities/bag_entity.dart';
import '../controllers/bag_list_controller.dart';
import '../widgets/bag_list_item.dart';

class BagListView extends GetView<BagListController> {
  const BagListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppStrings.bagList,
        showNotification: false,
        actions: [
          // `noWorkVisible`/`noWorkRunning` read here, inside this Obx's own
          // builder, for the same dependency-tracking reason as the
          // counters' Obx below — see that comment. Hidden once a session
          // is running (`noWorkRunning`), not just disabled.
          Obx(
            () =>
                (controller.noWorkVisible.value &&
                    !controller.noWorkRunning.value)
                ? _NoWorkButton(onTap: controller.onNoWorkTap)
                : const SizedBox.shrink(),
          ),
          // Shown to the left of the bag count whenever a "No Work" session
          // is currently running (`no_work_status == "Y"` and
          // `no_work_running == "S"`, or this session's own tap just
          // started one) — read here for the same reason as the Obx above.
          Obx(
            () => controller.noWorkRunning.value
                ? const _NoWorkRunningIndicator()
                : const SizedBox.shrink(),
          ),
          // `bagCount`/`pcsCount` are read here, inside the Obx builder, so
          // GetX is actually tracking them as dependencies for this Obx —
          // reading them one level down, inside _BagListCounters' own
          // build(), would not register as a dependency and the pills
          // would never update after the initial (zero) build.
          Obx(
            () => _BagListCounters(
              bagCount: controller.bagCount.value,
              pcsCount: controller.pcsCount.value,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final int columns =
                constraints.maxWidth > AppDimensions.breakpointTablet
                ? 3
                : constraints.maxWidth > AppDimensions.breakpointPhone
                ? 2
                : 1;

            return Obx(() {
              // Materialized here, inside the Obx builder, so GetX is
              // actually tracking `items` as a dependency of this Obx.
              // Passing `controller.items` straight through as a
              // constructor argument does not count as a "read" — the
              // list only gets iterated later, inside ReportListScaffold's
              // own build(), by which point GetX's dependency tracking for
              // *this* Obx has already closed. `onQueryChanged` no longer
              // touches `isLoading`/`errorMessage` (it filters purely
              // in-memory, no network call — see BagListController), so
              // this Obx would otherwise never rebuild after a search or a
              // clear.
              final List<BagEntity> items = List<BagEntity>.of(
                controller.items,
              );

              // Shows the exact text that was searched (including a
              // scanned barcode's raw value) so a mismatch between what
              // was scanned and the stored bag/design number is visible
              // right in the empty state, not just in the debug console.
              final String query = controller.query.value;
              final String? emptyMessage = query.isEmpty
                  ? null
                  : 'No bag found for "$query"';

              return ReportListScaffold(
                isLoading: controller.isLoading.value,
                errorMessage: controller.errorMessage.value,
                items: items,
                emptyMessage: emptyMessage,
                onRefresh: controller.refreshData,
                onSearchChanged: controller.onQueryChanged,
                searchHint: 'Search by bag no. or design no.',
                // Tightens the gap above the grid — the masonry list's own
                // top padding (spacingMd) already provides some separation,
                // so the search field doesn't need its full default bottom
                // padding on top of that.
                searchPadding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingXs,
                ),
                masonryColumnCount: columns,
                searchController: controller.searchController,
                searchSuggestionsBuilder: controller.suggestionsFor,
                searchBarTrailing: ScanButton(onScanned: controller.onScanned),
                itemBuilder: (context, bag) => BagListItem(
                  bag: bag,
                  onDone: controller.onBagDone,
                  onViewMedia: controller.openMediaGallery,
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

/// Sits between the "No Work" button and the bag/pcs counter pills — so
/// still to the left of the bag count — whenever a "No Work" session is
/// currently running. Text is capped to a fixed width with ellipsis so it
/// can't itself blow out the app bar's fixed-height actions row on a
/// narrow screen.
class _NoWorkRunningIndicator extends StatelessWidget {
  const _NoWorkRunningIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
      child: SizedBox(
        width: 130,
        child: Text(
          AppStrings.noWorkTimeStarted,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize:
                (Theme.of(context).textTheme.labelSmall?.fontSize ?? 11) + 2,
          ),
        ),
      ),
    );
  }
}

/// Sits to the left of the bag/pcs counter pills in the app bar's trailing
/// area.
class _NoWorkButton extends StatelessWidget {
  const _NoWorkButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
      child: Material(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_off_outlined,
                  size: AppDimensions.iconSm,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(width: AppDimensions.spacingXxs),
                Text(
                  AppStrings.noWork,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
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

/// "N Bags / N Pcs" summary shown in the app bar's trailing area.
class _BagListCounters extends StatelessWidget {
  const _BagListCounters({required this.bagCount, required this.pcsCount});

  final int bagCount;
  final int pcsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingMd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterPill(
            leading: Icon(
              Icons.shopping_bag_outlined,
              size: AppDimensions.iconSm,
              color: AppColors.info,
            ),
            value: bagCount,
            label: AppStrings.totalBags,
            color: AppColors.info,
            backgroundColor: AppColors.infoContainer,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          _CounterPill(
            // No jewelry-ring glyph exists in Flutter's built-in Material
            // Icons font, so a "finger ring with diamond" is rendered as
            // its emoji instead of an Icon(IconData).
            leading: Text(
              '💍',
              style: TextStyle(fontSize: AppDimensions.iconSm),
            ),
            value: pcsCount,
            label: AppStrings.totalPcs,
            color: AppColors.warning,
            backgroundColor: AppColors.warningContainer,
          ),
        ],
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.leading,
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final Widget leading;
  final int value;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: AppDimensions.spacingXxs),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXxs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
