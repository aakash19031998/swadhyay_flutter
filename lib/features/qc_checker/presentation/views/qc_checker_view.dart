import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../qc_pending_dashboard/domain/entities/department_entity.dart';
import '../../../qc_pending_dashboard/domain/entities/dia_qc_checker_entity.dart';
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
            _DepartmentSidebar(controller: controller),
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
                              child: _DiamondQcCheckerField(
                                controller: controller,
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
                            _ScanButton(onScanned: controller.onScanned),
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

/// "Diamond QC Checker" dropdown — UI copied from the QC Pending
/// Dashboard's own filter field (`_DiamondQcCheckerFilterField`);
/// `QcCheckerController.diaQcCheckers` is populated from `QCDepartmentN`'s
/// `DiaQcList`, fetched alongside the department sidebar's own list.
class _DiamondQcCheckerField extends StatelessWidget {
  const _DiamondQcCheckerField({required this.controller});

  final QcCheckerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<DiaQcCheckerEntity> options = controller.diaQcCheckers;
      final DiaQcCheckerEntity? selected =
          controller.selectedDiaQcChecker.value;

      return DropdownButtonFormField<DiaQcCheckerEntity>(
        initialValue: selected,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecondary,
        ),
        hint: Text(
          AppStrings.selectDiamondQcChecker,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.diamond_outlined, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.radiusMd),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXs,
            vertical: AppDimensions.spacingSm,
          ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
        items: [
          for (final option in options)
            DropdownMenuItem(
              value: option,
              child: Text(
                '${option.qcName} (${option.qcCode})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: options.isEmpty
            ? null
            : (value) => controller.selectDiaQcChecker(value!),
      );
    });
  }
}

/// Persistent department list — same UI/behavior as the QC Pending
/// Dashboard's own `_DepartmentSidebar`: nothing loads until one is
/// tapped, no "All Departments" option.
class _DepartmentSidebar extends StatelessWidget {
  const _DepartmentSidebar({required this.controller});

  final QcCheckerController controller;

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
                  const Icon(
                    Icons.apartment_outlined,
                    size: AppDimensions.iconSm,
                    color: AppColors.primary,
                  ),
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
                final List<DepartmentEntity> departments =
                    controller.departments;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXs,
                  ),
                  itemCount: departments.length,
                  itemBuilder: (context, i) {
                    final DepartmentEntity department = departments[i];
                    return Obx(() {
                      final bool selected =
                          controller.selectedDepartment.value?.id ==
                          department.id;
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
  const _DepartmentTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
                    color: selected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
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
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
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

/// Same scanner flow as `QcBagListView`'s own `_ScanButton` — opens
/// [AppRoutes.bagScanner] and drops a scanned value straight into the
/// search field, immediately loading the list (unlike typing, there's no
/// separate "Show" tap to wait for once a barcode's been read).
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onScanned});

  final ValueChanged<String> onScanned;

  Future<void> _openScanner() async {
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
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
