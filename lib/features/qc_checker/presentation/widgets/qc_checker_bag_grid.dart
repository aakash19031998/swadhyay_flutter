import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';

/// Same masonry layout as the QC Pending Dashboard's own `QcBagListView`
/// (`_BagGrid`) — duplicated here rather than imported since that's private
/// to that file, same as `_ScanButton`/`_DepartmentSidebar` are already
/// duplicated between the two QC features elsewhere in this codebase. The
/// card itself (`_BagCard`) is its own, more modern design: no OK/Repair
/// footer — tapping the thumbnail opens the image/video gallery (same
/// shared media viewer as the rest of the app), tapping anywhere else on
/// the card opens the new Bag Info/Repair Details screen (that screen
/// already offers both actions directly).
class QcCheckerBagGrid extends StatelessWidget {
  const QcCheckerBagGrid({
    required this.bags,
    required this.onOpenDetail,
    required this.onOpenMedia,
    super.key,
  });

  final List<QcAssignedBagEntity> bags;
  final ValueChanged<QcAssignedBagEntity> onOpenDetail;
  final ValueChanged<QcAssignedBagEntity> onOpenMedia;

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int c = 0; c < columnCount; c++) ...[
                if (c > 0) const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    children: [
                      for (final bag in columns[c]) ...[
                        _BagCard(
                          bag: bag,
                          onOpenDetail: () => onOpenDetail(bag),
                          onOpenMedia: () => onOpenMedia(bag),
                        ),
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
  const _BagCard({
    required this.bag,
    required this.onOpenDetail,
    required this.onOpenMedia,
  });

  final QcAssignedBagEntity bag;
  final VoidCallback onOpenDetail;
  final VoidCallback onOpenMedia;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Its own tap target — opens the image/video gallery,
                // separate from the rest of the card (see [onOpenDetail]).
                _BagThumbnail(imageUrl: bag.imageUrl, onTap: onOpenMedia),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onOpenDetail,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  bag.bagNo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bag.style,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Wrap(
                            spacing: AppDimensions.spacingXs,
                            runSpacing: AppDimensions.spacingXs,
                            children: [
                              _Pill(
                                icon: Icons.verified_outlined,
                                label: bag.process,
                                background: AppColors.successContainer,
                                foreground: AppColors.success,
                              ),
                              _Pill(
                                icon: Icons.layers_outlined,
                                label: '${bag.pieces} ${AppStrings.totalPcs}',
                                background: AppColors.warningContainer,
                                foreground: AppColors.warning,
                              ),
                              if (bag.artistCd != null)
                                _Pill(
                                  icon: Icons.badge_outlined,
                                  label: 'Emp: ${bag.artistCd}',
                                  background: AppColors.infoContainer,
                                  foreground: AppColors.info,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenDetail,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: AppDimensions.spacingXs),
                    // Below the image, flush with its left edge — not
                    // indented to align under the bagNo/style/chips column.
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.spacingXxs),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${AppStrings.orderNo}:  ',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                TextSpan(
                                  text: bag.orderNo,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: AppDimensions.spacingXxs),
                        Expanded(
                          child: Text(
                            '${AppStrings.firstReceived}: ${DateTimeHelper.formatDateTime(bag.firstRecDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed square image chip on the left, inset from the card's edges by the
/// same padding as the details column to its right. A dynamic "match the
/// details column's exact height" version was tried via `IntrinsicHeight` +
/// `AspectRatio`/`LayoutBuilder`, but both combinations produced real
/// layout bugs (an off-by-~33px overflow, then a full render-tree failure)
/// once the details column grew a `Wrap` — `Wrap`'s intrinsic-height
/// calculation is only an approximation, which is exactly what
/// `IntrinsicHeight` needs to be exact. A fixed size sized close to the
/// card's typical content height is the robust tradeoff.
class _BagThumbnail extends StatelessWidget {
  const _BagThumbnail({required this.imageUrl, required this.onTap});

  final String? imageUrl;
  final VoidCallback onTap;

  static const double _size = 108;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: imageUrl == null
              ? const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textHint,
                  size: AppDimensions.iconLg,
                )
              : Image.network(
                  imageUrl!,
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textHint,
                    size: AppDimensions.iconLg,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 12,
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
