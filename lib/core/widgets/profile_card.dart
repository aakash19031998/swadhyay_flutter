import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../extensions/string_extensions.dart';
import '../theme/app_colors.dart';

/// Drawer header card: avatar, employee name, employee code and punch-in
/// date/time — the identity summary shown at the top of the navigation
/// drawer.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.name,
    required this.empCode,
    super.key,
    this.inTimeLabel,
    this.avatarUrl,
    this.department,
    this.avatarSize = AppDimensions.avatarLg,
    this.padding = const EdgeInsets.fromLTRB(
      AppDimensions.spacingLg,
      AppDimensions.spacingXxl,
      AppDimensions.spacingLg,
      AppDimensions.spacingLg,
    ),
  });

  final String name;
  final String empCode;
  final String? inTimeLabel;
  final String? avatarUrl;
  final String? department;
  final double avatarSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: -60,
            right: -40,
            child: _HeaderBlob(size: 140, opacity: 0.10),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.onPrimary.withValues(alpha: 0.35),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.18),
                  backgroundImage: avatarUrl == null ? null : CachedNetworkImageProvider(avatarUrl!),
                  child: avatarUrl == null
                      ? Text(
                          name.initials,
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Wrap(
                      spacing: AppDimensions.spacingXs,
                      runSpacing: AppDimensions.spacingXs,
                      children: [
                        _InfoChip(icon: Icons.badge_outlined, label: '${AppStrings.empCode} $empCode'),
                        if (department != null)
                          _InfoChip(icon: Icons.apartment_outlined, label: department!),
                        if (inTimeLabel != null)
                          _InfoChip(icon: Icons.access_time_rounded, label: inTimeLabel!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

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
        color: AppColors.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: AppColors.onPrimary.withValues(alpha: 0.9)),
          const SizedBox(width: AppDimensions.spacingXxs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBlob extends StatelessWidget {
  const _HeaderBlob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.onPrimary.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
