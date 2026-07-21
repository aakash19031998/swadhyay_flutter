import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/report_list_scaffold.dart';
import '../controllers/skip_bag_controller.dart';
import '../widgets/skipped_bag_item.dart';

class SkipBagView extends GetView<SkipBagController> {
  const SkipBagView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: AppStrings.skipBag, showNotification: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: AppCard(child: _SkipBagForm(controller: controller)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(AppStrings.skipHistory, style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            Expanded(
              child: Obx(
                () => ReportListScaffold(
                  isLoading: controller.isLoading.value,
                  errorMessage: controller.errorMessage.value,
                  items: controller.items,
                  onRefresh: controller.refreshData,
                  onSearchChanged: controller.onQueryChanged,
                  searchHint: 'Search skip history by bag no.',
                  itemBuilder: (context, bag) => SkippedBagItem(bag: bag),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkipBagForm extends StatelessWidget {
  const _SkipBagForm({required this.controller});

  final SkipBagController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: AppStrings.bagNumber,
            hint: AppStrings.bagNumberHint,
            controller: controller.bagNumberController,
            prefixIcon: Icons.qr_code_2_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.trim().isEmpty ? '${AppStrings.bagNumber} is required' : null,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Obx(
            () => AppDropdown<String>(
              label: AppStrings.reason,
              value: controller.selectedReason.value,
              items: SkipBagController.reasons,
              itemLabel: (item) => item,
              onChanged: (value) {
                if (value != null) controller.selectedReason.value = value;
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Obx(
            () => AppButton(
              label: AppStrings.skipBagAction,
              isLoading: controller.isSubmitting.value,
              onPressed: controller.submit,
            ),
          ),
        ],
      ),
    );
  }
}
