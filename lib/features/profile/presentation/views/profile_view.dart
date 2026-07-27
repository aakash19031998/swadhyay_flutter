import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../authentication/domain/entities/employee_entity.dart';
import '../controllers/profile_controller.dart';

/// Read-only employee profile — opened by tapping the drawer header.
/// A hero identity card (avatar + name only), then the rest of the detail
/// as paired, colorful icon tiles: Emp. Code & Department, In Time &
/// Company Code, Total Hrs Till Date & OT Hrs, and Present Days alone.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeEntity employee = controller.employee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: AppStrings.profile, showNotification: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeroCard(employee: employee),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _DetailsGrid(employee: employee),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White identity card: avatar (gradient circle + online-status dot),
/// name, and a department pill.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.employee});

  final EmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingLg,
        horizontal: AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: AppDimensions.profileHeroAvatarSize,
                height: AppDimensions.profileHeroAvatarSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  border: Border.all(color: AppColors.surface, width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: employee.avatarUrl == null
                      ? Text(
                          employee.name.initials,
                          style: textTheme.displaySmall?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                          child: CachedNetworkImage(
                            imageUrl: employee.avatarUrl!,
                            width: AppDimensions.profileHeroAvatarSize,
                            height: AppDimensions.profileHeroAvatarSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            employee.name,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// Emp. Code & Department, In Time & Company Code, Total Hrs Till Date & OT
/// Hrs, and Present Days alone — pairs of tiles, side by side on tablet
/// width or stacked on phone width. Sized by [IntrinsicHeight] (each pair's
/// own natural content height), never a fixed extent.
class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.employee});

  final EmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = [
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
      _InfoTile(
        icon: Icons.corporate_fare_outlined,
        color: AppColors.info,
        label: AppStrings.companyCodeLabel,
        value: employee.companyCode ?? '',
      ),
      _InfoTile(
        icon: Icons.schedule_outlined,
        color: AppColors.success,
        label: AppStrings.totalHrsTillDateLabel,
        value: employee.totalHoursTillDate ?? '',
      ),
      _InfoTile(
        icon: Icons.more_time_outlined,
        color: AppColors.warning,
        label: AppStrings.otHrsLabel,
        value: employee.otHours ?? '',
      ),
      _InfoTile(
        icon: Icons.event_available_outlined,
        color: AppColors.success,
        label: AppStrings.presentDaysLabel,
        value: employee.presentDays == null ? '' : '${employee.presentDays}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

        if (!isTablet) {
          return Column(
            children: [
              for (final tile in tiles) ...[
                tile,
                if (tile != tiles.last) const SizedBox(height: AppDimensions.spacingMd),
              ],
            ],
          );
        }

        // Paired 2-per-row (Emp Code & Department, In Time & Company Code,
        // Total Hrs Till Date & OT Hrs), with the odd one out (Present Days)
        // alone on its own row.
        final List<Widget> rows = [
          for (int i = 0; i < tiles.length; i += 2)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  if (i + 1 < tiles.length) ...[
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(child: tiles[i + 1]),
                  ],
                ],
              ),
            ),
        ];

        return Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1) const SizedBox(height: AppDimensions.spacingMd),
            ],
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
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
                  maxLines: 1,
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
