import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/flex_table.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../domain/entities/dashboard_kpi_detail_entity.dart';
import '../controllers/dashboard_kpi_detail_controller.dart';

/// Generic drill-down table opened by tapping any of the Dashboard's four
/// KPI cards — same [FlexTable] shell as Bag Detail's Diamond Details/Bag
/// RM Summary tables and Design Master's own tables, so all of them read as
/// one consistent table style across the app. Only the title/columns/rows
/// differ per [DashboardKpiDetailController.args].
class DashboardKpiDetailView extends GetView<DashboardKpiDetailController> {
  const DashboardKpiDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: controller.args.kind.detailTitle,
        showNotification: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                0,
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onQueryChanged,
                decoration: InputDecoration(
                  hintText: AppStrings.searchTable,
                  prefixIcon: const Icon(
                    Icons.search,
                    size: AppDimensions.iconSm,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingXs,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const HkLoaderCard();
                // Materialized here, inside the Obx builder, so GetX is
                // actually tracking `rows` as a dependency of this Obx —
                // passing `controller.rows` straight through as a
                // constructor argument does not count as a "read" (same
                // pitfall documented on BagListView's own Obx). Without
                // this, the table never rebuilds when `rows` changes on
                // its own, which is exactly what searching/clearing does.
                final List<List<String>> rows = List.of(controller.rows);
                return SingleChildScrollView(
                  child: _KpiDetailTable(
                    columns: controller.columns,
                    rows: rows,
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

class _KpiDetailTable extends StatelessWidget {
  const _KpiDetailTable({required this.columns, required this.rows});

  final List<DashboardKpiDetailColumn> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return FlexTable(
      isEmpty: rows.isEmpty,
      columns: [
        for (final column in columns)
          FlexColumn(label: column.label, flex: column.flex),
      ],
      rows: rows,
    );
  }
}
