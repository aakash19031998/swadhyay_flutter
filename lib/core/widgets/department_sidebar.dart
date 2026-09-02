import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/qc_pending_dashboard/domain/entities/department_entity.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// Persistent department list, 168px wide — used by both the QC Pending
/// Dashboard and QC Checker screens. Nothing loads until one is tapped, no
/// "All Departments" option. Reactive params (rather than already-resolved
/// plain values) so the same fine-grained rebuild shape as before is kept:
/// the loading/list swap rebuilds on [departments]/[isLoading] changes, and
/// each tile's own `Obx` rebuilds independently on [selectedDepartment]
/// changes, instead of every tile rebuilding together.
class DepartmentSidebar extends StatelessWidget {
  const DepartmentSidebar({
    required this.departments,
    required this.selectedDepartment,
    required this.isLoading,
    required this.onSelect,
    super.key,
  });

  final RxList<DepartmentEntity> departments;
  final Rxn<DepartmentEntity> selectedDepartment;
  final RxBool isLoading;
  final ValueChanged<DepartmentEntity> onSelect;

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
                if (isLoading.value) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                final List<DepartmentEntity> items = departments;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final DepartmentEntity department = items[i];
                    return Obx(() {
                      final bool selected = selectedDepartment.value?.id == department.id;
                      return _DepartmentTile(
                        label: department.name,
                        selected: selected,
                        onTap: () => onSelect(department),
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
