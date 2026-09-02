import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/department_sidebar.dart';
import '../../../../core/widgets/diamond_qc_checker_field.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../../core/widgets/scan_button.dart';
import '../controllers/qc_checker_controller.dart';
import '../widgets/qc_checker_bag_grid.dart';

/// The new, simplified "QC Checker" first screen — department sidebar,
/// Diamond QC Checker dropdown, bag search and scan only. Deliberately
/// does not include the QC Pending Dashboard's employee grid (see
/// `QcPendingDashboardView` for that full screen, which this one does not
/// reuse or replace).
class QcCheckerView extends GetView<QcCheckerController> {
  const QcCheckerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: AppStrings.qcChecker,
        showNotification: false,
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DepartmentSidebar(
              departments: controller.departments,
              selectedDepartment: controller.selectedDepartment,
              isLoading: controller.isLoadingDepartments,
              onSelect: controller.selectDepartment,
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: Obx(() {
                // Diamond QC Checker/Search/Scan stay hidden until a
                // department is picked in the sidebar — nothing to filter
                // or scan into before then.
                if (controller.selectedDepartment.value == null) {
                  return const AppEmptyWidget(
                    message: AppStrings.selectDepartmentPrompt,
                    icon: Icons.apartment_outlined,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: DiamondQcCheckerField(
                                options: controller.diaQcCheckers,
                                selected: controller.selectedDiaQcChecker,
                                onSelect: controller.selectDiaQcChecker,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: AppSearchField(
                                onChanged: controller.onBagFieldChanged,
                                hint: 'Search by bag no.',
                                controller: controller.searchController,
                                fillColor: AppColors.surface,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: controller.searchController,
                              builder: (context, value, _) => _ShowButton(
                                onTap: value.text.trim().isEmpty
                                    ? null
                                    : controller.showBagResults,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            ScanButton(
                              onScanned: controller.onScanned,
                              height: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingBagResults.value) {
                          return const HkLoaderCard();
                        }

                        // The bag list only shows once something's been
                        // typed/scanned.
                        if (controller.bagResults.isEmpty) {
                          return AppEmptyWidget(
                            message: controller.searchedBagNo.value != null
                                ? 'QC Checker results for bag "${controller.searchedBagNo.value}" will appear here'
                                : 'QC Checker results for ${controller.selectedDepartment.value!.name} will appear here',
                            icon: Icons.qr_code_scanner_outlined,
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.spacingMd,
                            0,
                            AppDimensions.spacingMd,
                            AppDimensions.spacingMd,
                          ),
                          child: QcCheckerBagGrid(
                            bags: controller.bagResults,
                            onOpenDetail: controller.openBagDetail,
                            onOpenMedia: controller.openBagMedia,
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}


/// Loads the bag list for whatever's currently typed in the search field —
/// typing alone no longer triggers it (see
/// `QcCheckerController.onBagFieldChanged`), only this explicit tap does.
class _ShowButton extends StatelessWidget {
  const _ShowButton({required this.onTap});

  /// `null` (and visibly disabled) until the search field has text — see
  /// the `ValueListenableBuilder` this is built from in `QcCheckerView`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.primary : AppColors.disabled,
      borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Center(
            child: Text(
              'Show',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
