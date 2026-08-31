import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../controllers/qc_checker_bag_detail_controller.dart';
import '../widgets/qc_repair_details_panel.dart';

/// Opened from a [QcCheckerBagGrid] card's OK or Repair tap — the same
/// Bag Info/Repair Details design built for the QC Checker screen, just as
/// its own full screen now instead of embedded below the search bar.
class QcCheckerBagDetailView extends GetView<QcCheckerBagDetailController> {
  const QcCheckerBagDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: controller.bag.bagNo,
        showNotification: false,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Obx(
            () => QcRepairDetailsPanel(
              bag: controller.bag,
              checklist: controller.repairChecklist,
              isLoadingChecklist: controller.isLoadingChecklist.value,
              checkerName: controller.checkerName,
              isSubmittingOk: controller.isSubmittingOk.value,
              isSubmittingRepair: controller.isSubmittingRepair.value,
              onOk: controller.onOk,
              onSubmitRepair: controller.onSubmitRepair,
            ),
          ),
        ),
      ),
    );
  }
}
