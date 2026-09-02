import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/department_sidebar.dart';
import '../../../../core/widgets/diamond_qc_checker_field.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/qc_pending_dashboard_controller.dart';
import '../widgets/qc_check_card.dart';

class QcPendingDashboardView extends GetView<QcPendingDashboardController> {
  const QcPendingDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.qcPendingDashboard, showNotification: false),
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
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: Obx(() {
                // No "All Departments" option any more — nothing to show
                // until one is actually picked from the sidebar.
                if (controller.selectedDepartment.value == null) {
                  return const AppEmptyWidget(
                    message: AppStrings.selectDepartmentPrompt,
                    icon: Icons.apartment_outlined,
                  );
                }

                // Materialized here, inside the Obx builder, so GetX is
                // actually tracking `items` as a dependency of this Obx —
                // passing `controller.items` straight through as a
                // constructor argument does not count as a "read" (same
                // pitfall documented on BagListView's own Obx). Without
                // this, the grid never rebuilds when `items` changes on
                // its own, which is exactly what search filtering/clearing
                // does — `isLoading`/`errorMessage` don't change on a
                // search, so nothing else would trigger a rebuild.
                final items = List.of(controller.items);

                return ReportListScaffold(
                  isLoading: controller.isLoading.value,
                  errorMessage: controller.errorMessage.value,
                  items: items,
                  onRefresh: controller.refreshData,
                  onSearchChanged: controller.onQueryChanged,
                  searchHint: 'Search by emp code',
                  searchController: controller.searchController,
                  searchSuggestionsBuilder: controller.suggestionsFor,
                  searchBarLeading: Expanded(
                    child: DiamondQcCheckerField(
                      options: controller.diaQcCheckers,
                      selected: controller.selectedDiaQcChecker,
                      onSelect: controller.selectDiaQcChecker,
                      rebuildKey: controller.selectedDepartment.value?.id,
                    ),
                  ),
                  searchFillColor: AppColors.surface,
                  // Emp codes are numeric — restrict the field itself
                  // rather than relying on users to only type digits.
                  searchKeyboardType: TextInputType.number,
                  searchInputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // Tightened from the shared defaults so the grid sits
                  // right under the search field instead of the usual
                  // generous report-screen spacing.
                  searchPadding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacingMd,
                    AppDimensions.spacingMd,
                    AppDimensions.spacingMd,
                    AppDimensions.spacingXxs,
                  ),
                  // Masonry, not a fixed-aspect GridView: QcCheckCard's
                  // height is content-driven (avatar + emp code + emp
                  // name + stat chips), so a uniform forced cell height
                  // risks a "RenderFlex overflowed" error the moment
                  // content is taller than whatever aspect ratio was
                  // last hand-tuned. Each card keeps its own natural
                  // height here instead, so it can never overflow.
                  // Fixed at 5 per row per explicit request, with a
                  // tighter-than-default gap between cards.
                  masonryColumnCount: 5,
                  masonrySpacing: AppDimensions.spacingSm,
                  itemBuilder: (context, check) => QcCheckCard(
                    check: check,
                    onTap: () => controller.viewAssignedBags(check),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

