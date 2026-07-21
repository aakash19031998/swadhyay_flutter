import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/bag_list_controller.dart';
import '../widgets/bag_list_item.dart';

class BagListView extends GetView<BagListController> {
  const BagListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.bagList, showNotification: false),
      body: SafeArea(
        child: Obx(
          () => ReportListScaffold(
            isLoading: controller.isLoading.value,
            errorMessage: controller.errorMessage.value,
            items: controller.items,
            onRefresh: controller.refreshData,
            onSearchChanged: controller.onQueryChanged,
            searchHint: 'Search by bag no. or design no.',
            itemBuilder: (context, bag) => BagListItem(bag: bag, onDone: controller.onBagDone),
          ),
        ),
      ),
    );
  }
}
