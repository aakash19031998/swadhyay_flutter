import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/dia_qc_checker_entity.dart';
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
            _DepartmentSidebar(controller: controller),
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
                  searchBarLeading: Expanded(child: _DiamondQcCheckerFilterField(controller: controller)),
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

/// "Diamond QC Checker" filter — sits to the left of the search field, in
/// the same row. Bound to `DeptQCPendingEmpList`'s `DiaQcList` for the
/// currently selected department; the pick applies centrally to every
/// employee/bag until changed (see `QcPendingDashboardController.selectDiaQcChecker`
/// and `QcActionDialog`, which just displays it).
///
/// Keyed by the selected department's id so switching departments always
/// remounts this field fresh — `DropdownButtonFormField`'s `initialValue`
/// is otherwise only honored on first build, so without a fresh mount a
/// department switch wouldn't visibly clear the previous pick even though
/// `QcPendingDashboardController` already resets the underlying value.
class _DiamondQcCheckerFilterField extends StatelessWidget {
  const _DiamondQcCheckerFilterField({required this.controller});

  final QcPendingDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<DiaQcCheckerEntity> options = controller.diaQcCheckers;
      final DiaQcCheckerEntity? selected = controller.selectedDiaQcChecker.value;

      return DropdownButtonFormField<DiaQcCheckerEntity>(
        key: ValueKey(controller.selectedDepartment.value?.id),
        initialValue: selected,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
        hint: Text(
          AppStrings.selectDiamondQcChecker,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.diamond_outlined, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusMd))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs, vertical: AppDimensions.spacingSm),
          filled: true,
          fillColor: AppColors.surface,
        ),
        selectedItemBuilder: (context) => [
          for (final option in options)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option.qcName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
        items: [
          for (final option in options)
            DropdownMenuItem(
              value: option,
              child: Text('${option.qcName} (${option.qcCode})', overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: options.isEmpty ? null : (value) => controller.selectDiaQcChecker(value!),
      );
    });
  }
}

/// Persistent department list — same pattern as Brand Specification's
/// "SELECT BRAND" sidebar (no "All Departments" option): nothing loads
/// until one is tapped, matching `QcPendingDashboardController.fetch`'s guard on
/// `selectedDepartment == null`.
class _DepartmentSidebar extends StatelessWidget {
  const _DepartmentSidebar({required this.controller});

  final QcPendingDashboardController controller;

  static const double _width = 168;

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
                AppDimensions.spacingSm,
                AppDimensions.spacingSm,
                AppDimensions.spacingSm,
                AppDimensions.spacingXs,
              ),
              child: Row(
                children: [
                  const Icon(Icons.apartment_outlined, size: AppDimensions.iconSm, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spacingXxs),
                  Expanded(
                    child: Text(
                      AppStrings.selectDepartment.toUpperCase(),
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingDepartments.value) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                final List<DepartmentEntity> departments = controller.departments;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
                  itemCount: departments.length,
                  itemBuilder: (context, i) {
                    final DepartmentEntity department = departments[i];
                    return Obx(() {
                      final bool selected = controller.selectedDepartment.value?.id == department.id;
                      return _DepartmentTile(
                        label: department.name,
                        selected: selected,
                        onTap: () => controller.selectDepartment(department),
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

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXs,
              vertical: AppDimensions.spacingXs,
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label.isEmpty ? '?' : label[0].toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? AppColors.onPrimary : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
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
