import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/domain/entities/employee_entity.dart';
import '../controllers/profile_controller.dart';

/// Read-only employee profile — opened by tapping the drawer header.
/// Cover-banner hero with an overlapping circular avatar, then the rest of
/// the detail as a set of colorful icon tiles rather than boxed form
/// fields, so it reads as a profile page instead of a data-entry form.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeEntity employee = controller.employee;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(employee: employee),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;
                        return _InfoTiles(employee: employee, isTablet: isTablet);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.employee});

  final EmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppDimensions.radiusXl),
                bottomRight: Radius.circular(AppDimensions.radiusXl),
              ),
              child: Container(
                width: double.infinity,
                height: AppDimensions.profileBannerHeight,
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
                    const Positioned(top: -50, right: -30, child: _Blob(size: 140, opacity: 0.10)),
                    const Positioned(bottom: -40, left: -40, child: _Blob(size: 130, opacity: 0.08)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
                          onPressed: Get.back,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -AppDimensions.profileHeroAvatarSize / 2,
              child: Container(
                width: AppDimensions.profileHeroAvatarSize,
                height: AppDimensions.profileHeroAvatarSize,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage:
                      employee.avatarUrl == null ? null : CachedNetworkImageProvider(employee.avatarUrl!),
                  child: employee.avatarUrl == null
                      ? Text(
                          employee.name.initials,
                          style: textTheme.displayMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.profileHeroAvatarSize / 2 + AppDimensions.spacingSm),
        Text(
          employee.name,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (employee.department != null) ...[
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            employee.department!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: AppDimensions.spacingLg),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});

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

class _InfoTiles extends StatelessWidget {
  const _InfoTiles({required this.employee, required this.isTablet});

  final EmployeeEntity employee;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double? efficiency = _parseFraction(employee.workEfficiency);

    final List<Widget> pairedTiles = [
      _InfoTile(
        icon: Icons.badge_outlined,
        color: AppColors.primary,
        label: AppStrings.empCodeLabel,
        value: employee.empCode,
      ),
      _InfoTile(
        icon: Icons.apartment_outlined,
        color: AppColors.info,
        label: AppStrings.department,
        value: employee.department ?? '',
      ),
      _InfoTile(
        icon: Icons.access_time_rounded,
        color: AppColors.primary,
        label: AppStrings.inTimeLabel,
        value: employee.punchInAt == null ? '' : DateTimeHelper.formatDateTime(employee.punchInAt!),
      ),
      _EfficiencyTile(fraction: efficiency, rawValue: employee.workEfficiency),
      _InfoTile(
        icon: Icons.phone_outlined,
        color: AppColors.success,
        label: AppStrings.contactNumber,
        value: employee.contactNumber ?? '',
      ),
      _InfoTile(
        icon: Icons.phone_forwarded_outlined,
        color: AppColors.success,
        label: AppStrings.alternateContactNumber,
        value: employee.alternateContactNumber ?? '',
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < pairedTiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
            child: isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: pairedTiles[i]),
                      const SizedBox(width: AppDimensions.spacingMd),
                      Expanded(child: pairedTiles[i + 1]),
                    ],
                  )
                : Column(
                    children: [
                      pairedTiles[i],
                      const SizedBox(height: AppDimensions.spacingMd),
                      pairedTiles[i + 1],
                    ],
                  ),
          ),
        _InfoTile(
          icon: Icons.location_on_outlined,
          color: AppColors.warning,
          label: AppStrings.address,
          value: employee.address ?? '',
          maxLines: 3,
        ),
      ],
    );
  }

  double? _parseFraction(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final double? parsed = double.tryParse(raw.replaceAll('%', '').trim());
    if (parsed == null) return null;
    return (parsed / 100).clamp(0, 1);
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: AppDimensions.iconMd),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EfficiencyTile extends StatelessWidget {
  const _EfficiencyTile({required this.fraction, required this.rawValue});

  final double? fraction;
  final String? rawValue;

  @override
  Widget build(BuildContext context) {
    if (fraction == null) {
      return _InfoTile(
        icon: Icons.speed_outlined,
        color: AppColors.textSecondary,
        label: AppStrings.workEfficiency,
        value: rawValue ?? '',
      );
    }

    final Color color = fraction! >= 0.8
        ? AppColors.success
        : fraction! >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.speed_outlined, color: color, size: AppDimensions.iconMd),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                AppStrings.workEfficiency,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${(fraction! * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
