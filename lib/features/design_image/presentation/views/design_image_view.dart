import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/connectivity_checker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../controllers/design_image_controller.dart';
import '../widgets/design_image_tile.dart';

/// [CommonAppBar] gives this screen the same back button + title toolbar as
/// every other screen; the pill search field and gallery-card grid below it
/// are this screen's own look.
class DesignImageView extends GetView<DesignImageController> {
  const DesignImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: AppStrings.designImage, showNotification: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: _PillSearchField(onChanged: controller.onQueryChanged),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final int columns = Responsive.gridColumnsForWidth(constraints.maxWidth);

                  return Obx(() => _buildBody(context, columns));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, int columns) {
    if (controller.isLoading.value && controller.items.isEmpty) return const AppLoader();
    if (controller.errorMessage.value != null && controller.items.isEmpty) {
      return AppErrorWidget(message: controller.errorMessage.value!, onRetry: controller.refreshData);
    }
    if (controller.items.isEmpty) {
      return const AppEmptyWidget(message: AppStrings.noDesignsFound, icon: Icons.image_search_outlined);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          0,
          AppDimensions.spacingMd,
          AppDimensions.spacingMd,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppDimensions.spacingLg,
          mainAxisSpacing: AppDimensions.spacingLg,
          childAspectRatio: 0.8,
        ),
        itemCount: controller.items.length,
        itemBuilder: (context, index) => DesignImageTile(image: controller.items[index]),
      ),
    );
  }
}

/// Pill-shaped, debounced search field — same debounce behavior as the
/// shared `AppSearchField`, styled to this screen's rounded look instead.
class _PillSearchField extends StatefulWidget {
  const _PillSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_PillSearchField> createState() => _PillSearchFieldState();
}

class _PillSearchFieldState extends State<_PillSearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      if (!await Get.find<ConnectivityChecker>().ensureConnected()) return;
      widget.onChanged(value);
    });
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: AppStrings.designImageSearchHint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
        contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
    );
  }
}
