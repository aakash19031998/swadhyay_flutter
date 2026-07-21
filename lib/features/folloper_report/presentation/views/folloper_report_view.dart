import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/folloper_report_controller.dart';
import '../widgets/folloper_report_item.dart';

class FolloperReportView extends GetView<FolloperReportController> {
  const FolloperReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.folloperReport, showNotification: false),
      body: SafeArea(
        child: Obx(
          () => ReportListScaffold(
            isLoading: controller.isLoading.value,
            errorMessage: controller.errorMessage.value,
            items: controller.items,
            onRefresh: controller.refreshData,
            onSearchChanged: controller.onQueryChanged,
            searchHint: 'Search by folloper or artist name',
            itemBuilder: (context, entry) => FolloperReportItem(entry: entry),
          ),
        ),
      ),
    );
  }
}
