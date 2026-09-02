import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../../../core/widgets/scan_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/qc_assigned_bag_entity.dart';
import '../controllers/qc_bag_list_controller.dart';

/// Opened from a [QcCheckCard] tap: that employee's header stats, then a
/// search + scan bar (same mechanism as Bag List's own), then a grid of
/// cards for their currently assigned bags.
class QcBagListView extends GetView<QcBagListController> {
  const QcBagListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: AppStrings.qcBagListTitle,
        showNotification: false,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: _EmployeeHeaderCard(controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      onChanged: controller.onQueryChanged,
                      hint: 'Search by bag no. or order no.',
                      controller: controller.searchController,
                      suggestionsBuilder: controller.suggestionsFor,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  ScanButton(onScanned: controller.onScanned),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: Obx(() {
                // Materialized here, inside the Obx builder, so GetX is
                // actually tracking `items` as a dependency of this Obx —
                // see the identical note on QcPendingDashboardView/BagListView.
                final List<QcAssignedBagEntity> items = List.of(
                  controller.items,
                );

                if (controller.isLoading.value && items.isEmpty) {
                  return const HkLoaderCard();
                }
                if (controller.errorMessage.value != null && items.isEmpty) {
                  return AppErrorWidget(
                    message: controller.errorMessage.value!,
                    onRetry: controller.refreshData,
                  );
                }
                if (items.isEmpty) {
                  return AppEmptyWidget(
                    message: controller.query.value.isEmpty
                        ? AppStrings.noDataFound
                        : 'No bag found for "${controller.query.value}"',
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshData,
                  child: _BagGrid(
                    bags: items,
                    onImageTap: controller.openBagMedia,
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

class _EmployeeHeaderCard extends StatelessWidget {
  const _EmployeeHeaderCard({required this.controller});

  final QcBagListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child:
                      (controller.imageUrl == null ||
                          controller.imageUrl!.isEmpty)
                      ? const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        )
                      : Image.network(
                          controller.imageUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primaryContainer,
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                        ),
                ),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${controller.empName} (#${controller.empCode})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.activeQcQueueSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          _HeaderStat(
            label: AppStrings.qcTotalBags,
            value: '${controller.totalBags}',
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          _HeaderStat(
            label: AppStrings.totalPieces,
            value: '${controller.totalPieces}',
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 1 column on a narrow phone, 2 once there's room, 3 on a tablet-width
/// screen — same 3-tier breakpoints Bag List's own grid uses. Masonry, not
/// [GridView]: a fixed aspect ratio forces every card to a uniform cell
/// height, and when that guessed height doesn't match the card's actual
/// content height, `spaceBetween` inside the card stretches the pills/
/// title/quantity row apart with awkward gaps while the fixed-size
/// thumbnail sits unstretched next to them — exactly the "looks ugly"
/// mismatch this replaces. Each column here sizes purely from its own
/// cards' natural height instead (same fix `ReportListScaffold`'s own
/// masonry mode exists for).
class _BagGrid extends StatelessWidget {
  const _BagGrid({required this.bags, required this.onImageTap});

  final List<QcAssignedBagEntity> bags;
  final ValueChanged<QcAssignedBagEntity> onImageTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columnCount =
            constraints.maxWidth > AppDimensions.breakpointTablet
            ? 3
            : constraints.maxWidth > AppDimensions.breakpointPhone
            ? 2
            : 1;

        final List<List<QcAssignedBagEntity>> columns = List.generate(
          columnCount,
          (_) => <QcAssignedBagEntity>[],
        );
        for (int i = 0; i < bags.length; i++) {
          columns[i % columnCount].add(bags[i]);
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            0,
            AppDimensions.spacingMd,
            AppDimensions.spacingMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int c = 0; c < columnCount; c++) ...[
                if (c > 0) const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    children: [
                      for (final bag in columns[c]) ...[
                        _BagCard(bag: bag, onImageTap: () => onImageTap(bag)),
                        const SizedBox(height: AppDimensions.spacingMd),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BagCard extends StatelessWidget {
  const _BagCard({required this.bag, required this.onImageTap});

  final QcAssignedBagEntity bag;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BagThumbnail(imageUrl: bag.imageUrl, onTap: onImageTap),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bag.bagNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bag.style,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingXxs),
                          StatusPill(
                            icon: Icons.settings_outlined,
                            label: bag.process,
                            background: AppColors.successContainer,
                            foreground: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bag.orderNo,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          StatusPill(
                            icon: Icons.layers_outlined,
                            label: '${bag.pieces} ${AppStrings.totalPcs}',
                            background: AppColors.warningContainer,
                            foreground: AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        '${AppStrings.firstReceived}: ${DateTimeHelper.formatDateTimeColonSeconds(bag.firstRecDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BagThumbnail extends StatelessWidget {
  const _BagThumbnail({required this.imageUrl, required this.onTap});

  final String? imageUrl;
  final VoidCallback onTap;

  static const double _size = 92;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: imageUrl == null
              ? const SizedBox(
                  width: _size,
                  height: _size,
                  child: ColoredBox(color: AppColors.surfaceVariant),
                )
              : Image.network(
                  imageUrl!,
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: _size,
                      height: _size,
                      child: ColoredBox(
                        color: AppColors.surfaceVariant,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: _size,
                    height: _size,
                    child: ColoredBox(color: AppColors.surfaceVariant),
                  ),
                ),
        ),
      ),
    );
  }
}

