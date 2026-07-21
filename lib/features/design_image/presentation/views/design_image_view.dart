import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/design_image_controller.dart';
import '../widgets/design_image_tile.dart';

class DesignImageView extends GetView<DesignImageController> {
  const DesignImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.designImage, showNotification: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final int columns = Responsive.gridColumnsForWidth(constraints.maxWidth);

            return Obx(
              () => ReportListScaffold(
                isLoading: controller.isLoading.value,
                errorMessage: controller.errorMessage.value,
                items: controller.items,
                onRefresh: controller.refreshData,
                onSearchChanged: controller.onQueryChanged,
                searchHint: 'Search by design no. or category',
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppDimensions.spacingMd,
                  mainAxisSpacing: AppDimensions.spacingMd,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, image) => DesignImageTile(image: image),
              ),
            );
          },
        ),
      ),
    );
  }
}
