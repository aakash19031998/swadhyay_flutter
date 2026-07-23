import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/bag_list_controller.dart';
import '../widgets/bag_list_item.dart';

// Placeholder totals shown in the app bar. As of now these are static (not
// derived from the current/filtered list) — swap for a real summary source
// (e.g. an unfiltered totals endpoint) once one exists.
const int _staticBagCount = 18;
const int _staticImageCount = 72;

class BagListView extends GetView<BagListController> {
  const BagListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: AppStrings.bagList,
        showNotification: false,
        actions: [_BagListCounters(bagCount: _staticBagCount, imageCount: _staticImageCount)],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth > AppDimensions.breakpointTablet
                ? 3
                : constraints.maxWidth > AppDimensions.breakpointPhone
                    ? 2
                    : 1;

            return Obx(
              () => ReportListScaffold(
                isLoading: controller.isLoading.value,
                errorMessage: controller.errorMessage.value,
                items: controller.items,
                onRefresh: controller.refreshData,
                onSearchChanged: controller.onQueryChanged,
                searchHint: 'Search by bag no. or design no.',
                masonryColumnCount: columns,
                itemBuilder: (context, bag) => BagListItem(bag: bag, onDone: controller.onBagDone),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// "N Bags / N Images" summary shown in the app bar's trailing area.
class _BagListCounters extends StatelessWidget {
  const _BagListCounters({required this.bagCount, required this.imageCount});

  final int bagCount;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingMd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterPill(icon: Icons.shopping_bag_outlined, value: bagCount, label: AppStrings.totalBags),
          const SizedBox(width: AppDimensions.spacingSm),
          _CounterPill(icon: Icons.image_outlined, value: imageCount, label: AppStrings.totalImages),
        ],
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.icon, required this.value, required this.label});

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: AppColors.onPrimary),
          const SizedBox(width: AppDimensions.spacingXxs),
          Text(
            '$value',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: AppDimensions.spacingXxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}
