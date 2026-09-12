import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/view_eye_badge.dart';
import '../../domain/entities/bag_entity.dart';
import '../controllers/bag_timer_controller.dart';
import 'bag_action_button.dart';

/// One Bag List grid card: a bold hero Bag No. (the card's primary
/// identifier), full width, at the very top; then the image with its
/// floating quality badge; a 2x2 info grid below it (Style No./Department,
/// Bag Qty/Design Point); a points summary; and the productivity
/// clock/Start-Pause-Resume-Done actions driven by this bag's
/// [BagTimerController].
class BagListItem extends StatelessWidget {
  const BagListItem({
    required this.bag,
    required this.onViewMedia,
    super.key,
    this.onDone,
  });

  final BagEntity bag;
  final ValueChanged<BagEntity>? onDone;

  /// Fetches and opens this bag's image/video gallery — a fresh
  /// `ImageAndVideoUrls` call per tap (see `BagListController
  /// .openMediaGallery`), not a pre-loaded list, so tapping the thumbnail
  /// is never disabled up front the way an empty `bag.media` used to gate
  /// it.
  final ValueChanged<BagEntity> onViewMedia;

  BagTimerController get _timer => BagTimerController.of(bag);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BagIdentityHeader(bag: bag),
          const SizedBox(height: AppDimensions.spacingMd),
          _BagImageHeader(bag: bag, onViewMedia: onViewMedia),
          const SizedBox(height: AppDimensions.spacingMd),
          _BagInfoRow(bag: bag),
          const SizedBox(height: AppDimensions.spacingMd),
          _StatusRow(timer: _timer, bag: bag, onDone: onDone),
        ],
      ),
    );
  }
}

/// The card's hero identity row — Bag No. alone, full width, at the very
/// top of the card, using the same "icon badge + caption/value" tile
/// style as everything else on the card (see [_InfoTile]) with a trailing
/// eye icon; tapping it opens Bag Detail.
class _BagIdentityHeader extends StatelessWidget {
  const _BagIdentityHeader({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    return _InfoTile(
      icon: Icons.badge_outlined,
      caption: AppStrings.bagNoShort,
      value: bag.bagNo,
      color: AppColors.primary,
      valueStyle: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      trailing: const ViewEyeBadge(),
      onTap: () => Get.toNamed(AppRoutes.bagDetail, arguments: bag),
    );
  }
}

class _BagImageHeader extends StatelessWidget {
  const _BagImageHeader({required this.bag, required this.onViewMedia});

  final BagEntity bag;
  final ValueChanged<BagEntity> onViewMedia;

  @override
  Widget build(BuildContext context) {
    final bool isPremium = bag.filling.toUpperCase() == 'PREMIUM';

    // The bordered box is full-width, same footprint as before (so the
    // quality badge still floats on its corner exactly like previously) —
    // but the photo itself stays a small centered square inside it, with
    // white space either side, so a roughly-square product photo is never
    // stretched/cropped into an unnaturally wide letterbox.
    return Stack(
      children: [
        GestureDetector(
          onTap: () => onViewMedia(bag),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.bagCardImageSize,
                child: ColoredBox(
                  color: AppColors.surface,
                  child: Center(
                    child: SizedBox(
                      width: AppDimensions.bagCardImageSize,
                      height: AppDimensions.bagCardImageSize,
                      child: bag.imageUrl == null
                          ? const ColoredBox(
                              color: AppColors.surfaceVariant,
                              child: Icon(
                                Icons.diamond_outlined,
                                color: AppColors.textHint,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: bag.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const ColoredBox(
                                    color: AppColors.surfaceVariant,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                            ),
                    ),
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
        const Positioned(
          bottom: AppDimensions.spacingSm,
          right: AppDimensions.spacingSm,
          child: ViewEyeBadge(),
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

/// Style No. / Department / Bag Qty / Design Point as a 2x2 grid of info
/// tiles — each a colored icon badge beside a caption+value pair, sitting
/// below the image. Bag No. alone is promoted to its own full-width hero
/// row above (see [_BagIdentityHeader]).
class _BagInfoRow extends StatelessWidget {
  const _BagInfoRow({required this.bag});

  final BagEntity bag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoTileRow(
          left: _InfoTile(
            icon: Icons.style_outlined,
            caption: AppStrings.styleNo,
            value: bag.designNo,
            color: AppColors.textSecondary,
          ),
          right: _InfoTile(
            icon: Icons.layers_outlined,
            caption: AppStrings.department,
            value: bag.department,
            color: AppColors.info,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        _InfoTileRow(
          left: _InfoTile(
            icon: Icons.inventory_2_outlined,
            caption: AppStrings.bagQty,
            value: '${bag.bagQty}',
            color: AppColors.success,
          ),
          right: _InfoTile(
            caption: AppStrings.designPoints,
            value:
                '${bag.designPoints.toStringAsFixed(2)} × ${bag.bagQty} = '
                '${bag.totalPoints.toStringAsFixed(2)} Points',
            color: AppColors.primary,
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

/// One "icon badge + caption/value" tile used by [_BagInfoRow] and
/// [_BagIdentityHeader]. [trailing] and [onTap] are only set by the Bag
/// No. tile (its eye icon + tap-to-view-detail); [valueStyle] is only set
/// by the Bag No. tile too (bigger text). [icon] is null only for the
/// Design Point tile — omitting its badge frees up width so its (longer)
/// value text doesn't need to shrink as much to fit on one line.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.caption,
    required this.value,
    required this.color,
    this.icon,
    this.trailing,
    this.onTap,
    this.valueStyle,
  });

  final IconData? icon;
  final String caption;
  final String value;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Icon sits beside the caption/value column (not above it) per the
    // requested layout. Both text lines are wrapped in FittedBox so a long
    // value (e.g. a location code) scales down to fit the remaining width
    // instead of being cut off with an ellipsis.
    final Widget tile = Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: AppDimensions.iconMd,
              height: AppDimensions.iconMd,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                icon,
                size: AppDimensions.iconSm,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
          ],
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
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: (valueStyle ?? textTheme.titleSmall)?.copyWith(
                      color: color,
                      fontWeight: valueStyle == null
                          ? FontWeight.w800
                          : valueStyle!.fontWeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDimensions.spacingXs),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: tile,
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Disables the action buttons while a Start/Pause/Resume call is in
      // flight (read here, inside this Obx, so it's tracked the same way
      // as timer.status.value below) — prevents a slow response from being
      // triggered twice.
      final bool busy = timer.isProcessing.value;
      Widget? left;
      Widget? right;

      switch (timer.status.value) {
        case BagWorkStatus.notStarted:
          right = BagActionButton(
            label: AppStrings.start,
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onTap: busy ? null : () => timer.start(bag),
          );
        case BagWorkStatus.running:
          left = BagActionButton(
            label: AppStrings.pause,
            icon: Icons.pause_rounded,
            color: AppColors.warning,
            onTap: busy ? null : () => timer.pause(bag),
          );
          right = BagActionButton(
            label: AppStrings.done,
            icon: Icons.check_rounded,
            color: AppColors.success,
            onTap: () => onDone?.call(bag),
          );
        case BagWorkStatus.paused:
          // Only Resume shows while paused — Done is deliberately withheld
          // here (unlike the running case) since submitting a bag's
          // completed work while its own timer isn't actively running
          // isn't a state this flow allows.
          right = BagActionButton(
            label: AppStrings.resume,
            icon: Icons.play_arrow_rounded,
            color: AppColors.info,
            onTap: busy ? null : () => timer.resume(bag),
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
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: left ?? const SizedBox(),
            ),
          ),
          _ProductivityClock(timer: timer),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: right),
          ),
        ],
      );
    });
  }
}
