import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/design_image_entity.dart';

class DesignImageTile extends StatefulWidget {
  const DesignImageTile({required this.image, super.key});

  final DesignImageEntity image;

  @override
  State<DesignImageTile> createState() => _DesignImageTileState();
}

class _DesignImageTileState extends State<DesignImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translateByDouble(0.0, -6.0, 0.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.designCardRadius),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: _isHovered ? 0.12 : 0.04),
              blurRadius: _isHovered ? 25 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.designCardRadius),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.image.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppDimensions.spacingSm,
                    left: AppDimensions.spacingSm,
                    child: _CategoryBadge(label: widget.image.category),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESIGN NO.',
                    style: textTheme.labelSmall?.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppDimensions.spacingXxs),
                  Text(
                    widget.image.designNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXxs),
      decoration: BoxDecoration(
        color: AppColors.overlayScrim,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
