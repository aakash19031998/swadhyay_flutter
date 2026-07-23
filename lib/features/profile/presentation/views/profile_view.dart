import 'dart:math' as math;
import 'dart:ui';

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
/// A hero identity card, a work-efficiency card with a radial gauge, then
/// the rest of the detail as colorful icon tiles grouped under Personal
/// Details / Contact Details section headers.
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
                    _WorkEfficiencyHeroCard(employee: employee),
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
        vertical: AppDimensions.spacingXl,
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
                  shape: BoxShape.circle,
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
                      : ClipOval(
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
          if (employee.department != null) ...[
            const SizedBox(height: AppDimensions.spacingXs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingXxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                employee.department!,
                style: textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Green hero card with a radial gauge showing [EmployeeEntity.workEfficiency].
/// Chrome color stays on-brand green regardless of tier; the status pill
/// text ("Excellent" / "Good" / "Needs Improvement") carries the nuance.
class _WorkEfficiencyHeroCard extends StatelessWidget {
  const _WorkEfficiencyHeroCard({required this.employee});

  final EmployeeEntity employee;

  double? _parseFraction(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final double? parsed = double.tryParse(raw.replaceAll('%', '').trim());
    if (parsed == null) return null;
    return (parsed / 100).clamp(0, 1);
  }

  String _tierLabel(double fraction) {
    if (fraction >= 0.8) return AppStrings.performanceExcellent;
    if (fraction >= 0.5) return AppStrings.performanceGood;
    return AppStrings.performanceNeedsImprovement;
  }

  @override
  Widget build(BuildContext context) {
    final double? fraction = _parseFraction(employee.workEfficiency);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.success, AppColors.successDark],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(top: -50, right: -30, child: _Blob(size: 140, opacity: 0.10)),
          const Positioned(bottom: -40, left: -40, child: _Blob(size: 130, opacity: 0.08)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.performanceMetric.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXxs),
                    Text(
                      AppStrings.workEfficiency,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (fraction != null) ...[
                      const SizedBox(height: AppDimensions.spacingSm),
                      _FrostedPill(label: _tierLabel(fraction)),
                    ],
                  ],
                ),
              ),
              if (fraction != null) ...[
                const SizedBox(width: AppDimensions.spacingMd),
                _RadialGauge(fraction: fraction),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FrostedPill extends StatelessWidget {
  const _FrostedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            color: AppColors.onPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, size: AppDimensions.iconSm, color: AppColors.onPrimary),
              const SizedBox(width: AppDimensions.spacingXxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialGauge extends StatelessWidget {
  const _RadialGauge({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.profileGaugeSize,
      height: AppDimensions.profileGaugeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(AppDimensions.profileGaugeSize),
            painter: _RadialGaugePainter(
              fraction: fraction,
              trackColor: AppColors.onPrimary.withValues(alpha: 0.25),
              progressColor: AppColors.onPrimary,
            ),
          ),
          Text(
            '${(fraction * 100).round()}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  const _RadialGaugePainter({
    required this.fraction,
    required this.trackColor,
    required this.progressColor,
  });

  final double fraction;
  final Color trackColor;
  final Color progressColor;

  static const double _strokeWidth = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - _strokeWidth) / 2;

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
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

/// Emp. Code / Department / In Time — three tiles, laid out side by side on
/// tablet width or stacked on phone width. Sized by [IntrinsicHeight] (each
/// tile's own natural content height), never a fixed extent.
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

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: AppDimensions.spacingMd),
                Expanded(child: tiles[i]),
              ],
            ],
          ),
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
