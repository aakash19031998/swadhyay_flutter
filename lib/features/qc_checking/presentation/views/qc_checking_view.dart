import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/qc_checking_controller.dart';
import '../widgets/qc_check_item.dart';

class QcCheckingView extends GetView<QcCheckingController> {
  const QcCheckingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.qcChecking, showNotification: false),
      body: SafeArea(
        child: Obx(
          () => ReportListScaffold(
            isLoading: controller.isLoading.value,
            errorMessage: controller.errorMessage.value,
            items: controller.items,
            onRefresh: controller.refreshData,
            onSearchChanged: controller.onQueryChanged,
            searchHint: 'Search by bag no. or design no.',
            itemBuilder: (context, check) => QcCheckItem(check: check),
          ),
        ),
      ),
    );
  }
}
