import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
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
                searchController: controller.searchController,
                searchBarTrailing: _ScanButton(onScanned: controller.onScanned),
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
          _CounterPill(
            icon: Icons.shopping_bag_outlined,
            value: bagCount,
            label: AppStrings.totalBags,
            color: AppColors.info,
            backgroundColor: AppColors.infoContainer,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          _CounterPill(
            icon: Icons.image_outlined,
            value: imageCount,
            label: AppStrings.totalImages,
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
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
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
          Icon(icon, size: AppDimensions.iconSm, color: color),
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

/// Opens the bag scanner (front camera, requested at runtime) — sits to the
/// right of the search field, matching the search field's own height. A
/// scanned QR/barcode value is shown in the search field itself and applied
/// as the list's filter; the scanner screen closes back to this one.
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onScanned});

  final ValueChanged<String> onScanned;

  Future<void> _openScanner() async {
    // Deliberately untyped: Get.toNamed<String>(...) throws at runtime
    // ("GetPageRoute<dynamic> is not a subtype of Route<String?>") because
    // app_pages.dart's route table is registered as GetPage<dynamic> — the
    // generic type argument here fights that, not matches it. Casting the
    // dynamic result afterward avoids the mismatch entirely.
    final dynamic result = await Get.toNamed(AppRoutes.bagScanner);
    final String? scanned = result is String ? result : null;
    if (scanned != null && scanned.isNotEmpty) onScanned(scanned);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
        onTap: _openScanner,
        child: const SizedBox(
          width: AppDimensions.formFieldHeight,
          height: AppDimensions.formFieldHeight,
          child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
