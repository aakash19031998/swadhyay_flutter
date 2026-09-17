import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/bordered_surface_card.dart';
import '../../../../core/widgets/gradient_top_bar.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../../domain/entities/artist_profile_entity.dart';
import '../../domain/entities/earn_till_date_entity.dart';
import '../../domain/entities/incentive_field_entity.dart';
import '../controllers/earn_till_date_controller.dart';

/// The signed-in employee's own Earn Till Date: an identity/personal
/// dossier pair on the left, and the incentive stat cards + full
/// ticked-field table on the right — side by side on tablet width, stacked
/// on phone width. Placeholder data only (see
/// `EarnTillDateDataSource`'s own doc comment).
class EarnTillDateView extends GetView<EarnTillDateController> {
  const EarnTillDateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const GradientTopBar(title: AppStrings.earnTillDate),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const HkLoaderCard();
                if (controller.errorMessage.value != null) {
                  return AppErrorWidget(
                    message: controller.errorMessage.value!,
                    onRetry: controller.load,
                  );
                }

                final EarnTillDateEntity? data = controller.details.value;
                if (data == null) return const SizedBox.shrink();

                // Every card below sizes to its own natural content height
                // — nothing is stretched to force-fill the screen — so
                // there's never dead white space inside a card just
                // because its sibling column happens to be taller. This
                // outer scroll is a safety net only: the compact two-
                // column table and tightened dossier spacing already keep
                // real content short enough to need it in practice.
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isTablet =
                          constraints.maxWidth >= AppDimensions.breakpointPhone;

                      final Widget left = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ProfileCard(profile: data.profile),
                          const SizedBox(height: AppDimensions.spacingMd),
                          _PersonalDossierCard(profile: data.profile),
                        ],
                      );

                      final Widget right = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatsRow(data: data),
                          const SizedBox(height: AppDimensions.spacingMd),
                          _IncentiveTableCard(data: data),
                        ],
                      );

                      // On a phone-width screen, this two-column layout
                      // would cramp everything unreadably — stacking is
                      // the one exception, since the tablet/landscape
                      // layout above is this screen's actual design target.
                      if (!isTablet) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ProfileCard(profile: data.profile),
                            const SizedBox(height: AppDimensions.spacingMd),
                            _PersonalDossierCard(profile: data.profile),
                            const SizedBox(height: AppDimensions.spacingMd),
                            _StatsRow(data: data),
                            const SizedBox(height: AppDimensions.spacingMd),
                            _IncentiveTableCard(data: data),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: left),
                          const SizedBox(width: AppDimensions.spacingMd),
                          Expanded(flex: 3, child: right),
                        ],
                      );
                    },
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

/// Avatar + identity, a Department/Company fact box, and the Experience /
/// Recruited / Joined tile row.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final ArtistProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BorderedSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                clipBehavior: Clip.antiAlias,
                child: profile.photoUrl == null
                    ? Text(
                        profile.name.initials,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : Image.network(profile.photoUrl!, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXxs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                          ),
                          child: Text(
                            profile.staffType.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          '#${profile.empCode}',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                _LabelValueRow(
                  label: '${AppStrings.department}:',
                  value: profile.department,
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                _LabelValueRow(
                  label: '${AppStrings.company}:',
                  value: profile.companyLabel,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Expanded(
                child: _FactTile(
                  label: AppStrings.experience,
                  value: profile.experienceLabel,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: _FactTile(
                  label: AppStrings.recruited,
                  value: profile.recruitedDate,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: _FactTile(
                  label: AppStrings.joined,
                  value: profile.contractJoinedDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Age/DOB, Gender/Status, Religion/Caste, Mobile numbers and Email as
/// label/value rows, then Local/Native Address as their own boxes.
class _PersonalDossierCard extends StatelessWidget {
  const _PersonalDossierCard({required this.profile});

  final ArtistProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BorderedSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.personalDossier,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (profile.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.success),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.spacingXxs),
                      Text(
                        AppStrings.verified,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppDimensions.spacingXs),
          _DossierRow(label: AppStrings.ageDob, value: profile.ageDobLabel),
          _DossierRow(
            label: AppStrings.genderStatus,
            value: profile.genderStatus,
          ),
          _DossierRow(
            label: AppStrings.religionCaste,
            value: profile.religionCaste,
          ),
          _DossierRow(
            label: AppStrings.mobile,
            value: profile.mobile,
            valueColor: AppColors.primary,
          ),
          if (profile.altMobile != null)
            _DossierRow(label: AppStrings.altMobile, value: profile.altMobile!),
          _DossierRow(
            label: AppStrings.email,
            value: profile.email,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          _AddressBox(
            label: AppStrings.localAddress,
            value: profile.localAddress,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          _AddressBox(
            label: AppStrings.nativeAddress,
            value: profile.nativeAddress,
          ),
        ],
      ),
    );
  }
}

class _DossierRow extends StatelessWidget {
  const _DossierRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressBox extends StatelessWidget {
  const _AddressBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${label.toUpperCase()}:',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxs),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Fixed Salary / Commitment Salary / Hr Salary / Earn Till Date — four
/// headline stat cards, each with a colored top accent.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final EarnTillDateEntity data;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _IncentiveStatCard(
              title: AppStrings.fixedSalary,
              value: '₹${data.fixedSalary.toStringAsFixed(0)}',
              accentColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: _IncentiveStatCard(
              title: AppStrings.commitmentSalary,
              value: '₹${data.commitmentSalary.toStringAsFixed(0)}',
              accentColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: _IncentiveStatCard(
              title: AppStrings.hrSalary,
              value: '₹${data.hrSalary.toStringAsFixed(0)}',
              accentColor: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: _IncentiveStatCard(
              title: AppStrings.earnTillDate,
              value: '₹${data.earnTillDate.toStringAsFixed(0)}',
              accentColor: AppColors.success,
              valueColor: AppColors.success,
              highlighted: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncentiveStatCard extends StatelessWidget {
  const _IncentiveStatCard({
    required this.title,
    required this.value,
    required this.accentColor,
    this.valueColor,
    this.highlighted = false,
  });

  final String title;
  final String value;
  final Color accentColor;
  final Color? valueColor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // A `Border` can't mix colors when paired with `borderRadius` (Flutter
    // throws at paint time, leaving the whole card blank) — so the colored
    // top accent is its own strip above the content instead of a border
    // side, with a single uniform-color border wrapping the whole card.
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: accentColor),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            color: highlighted ? AppColors.successContainer : AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
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

/// The full "Incentive Details (Ticked Fields)" table — every metric/value
/// pair from the physical incentive paper record, split into two columns
/// (matching how long checklist-style tables render elsewhere in this app)
/// with a handful of rows highlighted (deductions, notable quantities, a
/// running total). Sized to its own natural content height (an even
/// `ceil(n/2)` split, not a height-fitting estimate) rather than stretched
/// to fill whatever space a sibling column happens to need — stretching it
/// is what left dead white space below whichever column ended up shorter.
class _IncentiveTableCard extends StatelessWidget {
  const _IncentiveTableCard({required this.data});

  final EarnTillDateEntity data;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<IncentiveFieldEntity> fields = data.fields;
    final int half = (fields.length / 2).ceil();
    final List<IncentiveFieldEntity> firstColumn = fields.sublist(0, half);
    final List<IncentiveFieldEntity> secondColumn = fields.sublist(half);

    return BorderedSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: AppDimensions.iconSm,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Expanded(
                child: Text(
                  AppStrings.earnTillDateTableTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final field in firstColumn)
                      _TableFieldRow(field: field),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Column(
                  children: [
                    for (final field in secondColumn)
                      _TableFieldRow(field: field),
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

class _TableFieldRow extends StatelessWidget {
  const _TableFieldRow({required this.field});

  final IncentiveFieldEntity field;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Any negative recorded value is flagged red regardless of the field's
    // own highlight — not just whichever row happens to be pre-marked as a
    // deduction — so a new negative figure is always caught automatically.
    final bool isNegative = field.recordedValue.trim().startsWith('-');
    final IncentiveFieldHighlight highlight = isNegative
        ? IncentiveFieldHighlight.warning
        : field.highlight;

    final (
      Color background,
      Color? accent,
      IconData? icon,
    ) = switch (highlight) {
      IncentiveFieldHighlight.warning => (
        AppColors.errorContainer,
        AppColors.error,
        Icons.warning_amber_rounded,
      ),
      IncentiveFieldHighlight.caution => (
        AppColors.warningContainer,
        AppColors.warning,
        null,
      ),
      IncentiveFieldHighlight.success => (
        AppColors.successContainer,
        AppColors.success,
        null,
      ),
      IncentiveFieldHighlight.info => (
        AppColors.infoContainer,
        AppColors.info,
        null,
      ),
      IncentiveFieldHighlight.none => (AppColors.background, null, null),
    };

    final FontWeight weight = field.isBold ? FontWeight.w800 : FontWeight.w500;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingXxs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${field.srNo}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    field.metricName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: accent ?? AppColors.textPrimary,
                      fontWeight: weight,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppDimensions.spacingXxs),
                  Icon(icon, size: AppDimensions.iconSm, color: accent),
                ],
              ],
            ),
          ),
          Text(
            field.unit == null
                ? field.recordedValue
                : '${field.recordedValue} ${field.unit}',
            style: textTheme.bodyMedium?.copyWith(
              color: accent ?? AppColors.textPrimary,
              fontWeight: weight,
            ),
          ),
        ],
      ),
    );
  }
}
