import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/bag_entity.dart';
import '../controllers/bag_media_viewer_args.dart';
import '../controllers/bag_timer_controller.dart';
import 'bag_action_button.dart';
import 'pause_reason_dialog.dart';

/// One Bag List grid card: image with a floating quality badge, a fixed
/// 2x2 info grid (Bag ID / Order No. on top, Department / Qty below), a
/// points summary, and the productivity clock/Start-Pause-Resume-Done
/// actions driven by this bag's [BagTimerController].
class BagListItem extends StatelessWidget {
  const BagListItem({required this.bag, super.key, this.onDone});

  final BagEntity bag;
  final ValueChanged<BagEntity>? onDone;

  BagTimerController get _timer => BagTimerController.of(bag.id);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BagImageHeader(bag: bag),
          const SizedBox(height: AppDimensions.spacingMd),
          _BagInfoGrid(bag: bag),
          const SizedBox(height: AppDimensions.spacingMd),
          _PointsSummary(bag: bag),
          const SizedBox(height: AppDimensions.spacingMd),
          _StatusRow(timer: _timer, bag: bag, onDone: onDone),
        ],
      ),
    );
  }
}

class _BagImageHeader extends StatelessWidget {
  const _BagImageHeader({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    final bool isPremium = bag.filling.toUpperCase() == 'PREMIUM';

    return Stack(
      children: [
        GestureDetector(
          onTap: bag.media.isEmpty
              ? null
              : () => Get.toNamed(
                    AppRoutes.bagMediaViewer,
                    arguments: BagMediaViewerArgs(media: bag.media),
                  ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.bagCardImageHeight,
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
        ),
        Positioned(
          top: AppDimensions.spacingSm,
          right: AppDimensions.spacingSm,
          child: _QualityBadge(label: bag.filling, isPremium: isPremium),
        ),
      ],
    );
  }
}

/// Solid, drop-shadowed pill for the quality tier — sits on top of a photo,
/// so unlike [StatusChip] (a soft alpha-tinted pill meant for plain
/// surfaces) it needs full-opacity color and its own shadow to stay legible.
class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.label, required this.isPremium});

  final String label;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final Color color = isPremium ? AppColors.warning : AppColors.info;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

/// Bag ID / Order No. / Department / Qty as four equal-width info tiles —
/// each a colored icon badge beside a caption+value pair — instead of a
/// free-flowing row of pill chips, so the four key identifiers always sit
/// fixed, aligned, and legible regardless of card width.
class _BagInfoGrid extends StatelessWidget {
  const _BagInfoGrid({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoTileRow(
          left: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.bagDetail, arguments: bag),
            child: _InfoTile(
              icon: Icons.badge_outlined,
              caption: AppStrings.bagNoShort,
              value: bag.bagNo,
              color: AppColors.primary,
            ),
          ),
          right: _InfoTile(
            icon: Icons.style_outlined,
            caption: AppStrings.styleNo,
            value: bag.designNo,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        _InfoTileRow(
          left: _InfoTile(
            icon: Icons.layers_outlined,
            caption: AppStrings.department,
            value: bag.department,
            color: AppColors.info,
          ),
          right: _InfoTile(
            icon: Icons.inventory_2_outlined,
            caption: AppStrings.bagQty,
            value: '${bag.bagQty}',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

/// Two tiles side by side, each given equal width. Split out from
/// [_BagInfoGrid] so both rows of the 2x2 layout share one
/// [IntrinsicHeight] rule: a Row is a non-flex child of a Column, so it's
/// handed unbounded height to size itself with — `stretch` would try to
/// force that unbounded height onto each tile and blow up layout, whereas
/// IntrinsicHeight measures the taller of the two tiles and gives both
/// exactly that height.
class _InfoTileRow extends StatelessWidget {
  const _InfoTileRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(child: right),
        ],
      ),
    );
  }
}

/// One "icon badge + caption/value" tile used by [_BagInfoGrid].
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.caption,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String caption;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Icon sits beside the caption/value column (not above it) per the
    // requested layout. Both text lines are wrapped in FittedBox so a long
    // value (e.g. a location code) scales down to fit the remaining width
    // instead of being cut off with an ellipsis.
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.iconMd,
            height: AppDimensions.iconMd,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: AppDimensions.iconSm, color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    caption,
                    maxLines: 1,
                    style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
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

class _PointsSummary extends StatelessWidget {
  const _PointsSummary({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${AppStrings.designPoints}: ${bag.designPoints.toStringAsFixed(2)} × ${bag.bagQty}',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            '${bag.totalPoints.toStringAsFixed(2)} ${AppStrings.totalPoints}',
            style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
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

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning ? Icons.timer_outlined : Icons.timer_off_outlined,
            size: AppDimensions.iconMd,
            color: isRunning ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            DateTimeHelper.formatStopwatch(timer.elapsed.value),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isRunning ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      );
    });
  }
}

/// Lays the timer and its Start/Pause/Resume/Done action(s) out as a fixed
/// three-slot row — [Expanded] on both sides of the (naturally sized)
/// clock, each aligned to its own outer edge — so the clock always sits
/// dead-center no matter which side has content and which is empty,
/// mirroring the pattern used by the bag detail screen's top bar.
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.timer, required this.bag, this.onDone});

  final BagTimerController timer;
  final BagEntity bag;
  final ValueChanged<BagEntity>? onDone;

  Future<void> _handlePause() async {
    final String? reason = await PauseReasonDialog.show();
    if (reason != null) timer.pause(reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget? left;
      Widget? right;

      switch (timer.status.value) {
        case BagWorkStatus.notStarted:
          right = BagActionButton(
            label: AppStrings.start,
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onTap: timer.start,
          );
        case BagWorkStatus.running:
          left = BagActionButton(
            label: AppStrings.pause,
            icon: Icons.pause_rounded,
            color: AppColors.warning,
            onTap: _handlePause,
          );
          right = BagActionButton(
            label: AppStrings.done,
            icon: Icons.check_rounded,
            color: AppColors.success,
            onTap: () {
              timer.done();
              onDone?.call(bag);
            },
          );
        case BagWorkStatus.paused:
          left = BagActionButton(
            label: AppStrings.resume,
            icon: Icons.play_arrow_rounded,
            color: AppColors.info,
            onTap: timer.resume,
          );
          right = BagActionButton(
            label: AppStrings.done,
            icon: Icons.check_rounded,
            color: AppColors.success,
            onTap: () {
              timer.done();
              onDone?.call(bag);
            },
          );
        case BagWorkStatus.done:
          right = BagActionButton(
            label: AppStrings.completed,
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            onTap: null,
          );
      }

      return Row(
        children: [
          Expanded(child: Align(alignment: Alignment.centerLeft, child: left ?? const SizedBox())),
          _ProductivityClock(timer: timer),
          Expanded(child: Align(alignment: Alignment.centerRight, child: right)),
        ],
      );
    });
  }
}
