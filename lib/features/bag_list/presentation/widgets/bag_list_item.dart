import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/bag_entity.dart';
import '../controllers/bag_media_viewer_args.dart';
import '../controllers/bag_timer_controller.dart';

class BagListItem extends StatelessWidget {
  const BagListItem({required this.bag, super.key, this.onDone});

  final BagEntity bag;
  final ValueChanged<BagEntity>? onDone;

  BagTimerController get _timer {
    if (Get.isRegistered<BagTimerController>(tag: bag.id)) {
      return Get.find<BagTimerController>(tag: bag.id);
    }
    return Get.put(BagTimerController(), tag: bag.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BagThumbnail(bag: bag),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(child: _BagDetails(bag: bag, timer: _timer)),
          const SizedBox(width: AppDimensions.spacingSm),
          _StatusActions(timer: _timer, bag: bag, onDone: onDone),
        ],
      ),
    );
  }
}

class _BagThumbnail extends StatelessWidget {
  const _BagThumbnail({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.bagListItemImageSize,
      child: Column(
        children: [
          GestureDetector(
            onTap: bag.media.isEmpty
                ? null
                : () => Get.toNamed(
                      AppRoutes.bagMediaViewer,
                      arguments: BagMediaViewerArgs(media: bag.media),
                    ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: SizedBox(
                width: AppDimensions.bagListItemImageSize,
                height: AppDimensions.bagListItemImageSize,
                child: bag.imageUrl == null
                    ? const ColoredBox(
                        color: AppColors.surfaceVariant,
                        child: Icon(Icons.diamond_outlined, color: AppColors.textHint),
                      )
                    : CachedNetworkImage(
                        imageUrl: bag.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const ColoredBox(
                          color: AppColors.surfaceVariant,
                          child: Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.bagDetail, arguments: bag),
            child: Text(
              bag.bagNo,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BagDetails extends StatelessWidget {
  const _BagDetails({required this.bag, required this.timer});

  final BagEntity bag;
  final BagTimerController timer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool isPremium = bag.filling.toUpperCase() == 'PREMIUM';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppDimensions.spacingXs,
          runSpacing: AppDimensions.spacingXxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FieldChip(icon: Icons.location_on_outlined, label: bag.locationCode),
            _FieldChip(icon: Icons.layers_outlined, label: AppStrings.filling),
            StatusChip(
              label: bag.filling,
              color: isPremium ? AppColors.warning : AppColors.info,
            ),
            _FieldChip(
              icon: Icons.inventory_2_outlined,
              label: '${AppStrings.bagQty} : ${bag.bagQty}',
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          '${AppStrings.designPoints}: ${bag.designPoints.toStringAsFixed(2)} x '
          '${AppStrings.bagQty}: ${bag.bagQty} = ${AppStrings.totalPoints}: ${bag.totalPoints.toStringAsFixed(2)}',
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        _ProductivityClock(timer: timer),
      ],
    );
  }
}

/// Neutral pill for a static field (location, a category tag) — visually
/// distinct from [StatusChip], which is reserved for a value that carries
/// meaning (status, filling type).
class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingXxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Reads [BagTimerController]'s reactive state inside its own [Obx] (rather
/// than relying on a parent one) so it stays correct regardless of how it's
/// composed into the surrounding widget tree.
class _ProductivityClock extends StatelessWidget {
  const _ProductivityClock({required this.timer});

  final BagTimerController timer;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isRunning = timer.status.value == BagWorkStatus.running;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacingXxs,
        ),
        decoration: BoxDecoration(
          color: (isRunning ? AppColors.success : AppColors.textHint).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRunning ? Icons.timer_outlined : Icons.timer_off_outlined,
              size: AppDimensions.iconSm,
              color: isRunning ? AppColors.success : AppColors.textHint,
            ),
            const SizedBox(width: AppDimensions.spacingXxs),
            Text(
              DateTimeHelper.formatStopwatch(timer.elapsed.value),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isRunning ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.timer, required this.bag, this.onDone});

  final BagTimerController timer;
  final BagEntity bag;
  final ValueChanged<BagEntity>? onDone;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (timer.status.value) {
        case BagWorkStatus.notStarted:
          return _ActionButton(
            label: AppStrings.start,
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onTap: timer.start,
          );
        case BagWorkStatus.running:
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionButton(
                label: AppStrings.pause,
                icon: Icons.pause_rounded,
                color: AppColors.warning,
                onTap: timer.pause,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              _ActionButton(
                label: AppStrings.done,
                icon: Icons.check_rounded,
                color: AppColors.success,
                onTap: () {
                  timer.done();
                  onDone?.call(bag);
                },
              ),
            ],
          );
        case BagWorkStatus.paused:
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionButton(
                label: AppStrings.resume,
                icon: Icons.play_arrow_rounded,
                color: AppColors.info,
                onTap: timer.resume,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              _ActionButton(
                label: AppStrings.done,
                icon: Icons.check_rounded,
                color: AppColors.success,
                onTap: () {
                  timer.done();
                  onDone?.call(bag);
                },
              ),
            ],
          );
        case BagWorkStatus.done:
          return const StatusChip(label: AppStrings.completed, color: AppColors.success);
      }
    });
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: AppDimensions.spacingXxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: AppColors.onPrimary),
              const SizedBox(width: AppDimensions.spacingXxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
