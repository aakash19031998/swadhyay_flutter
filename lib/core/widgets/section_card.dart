import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

/// Card shell used across detail-style screens: an optional title row
/// (icon + label) over a divider, then the section's own content — keeps
/// every card on a screen reading as one consistent design language
/// instead of several different ad hoc layouts.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.title,
    this.icon,
    this.padding,
    this.accentColor,
    this.expandChild = false,
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  /// Overrides the title row's icon-badge/text color (defaults to
  /// [AppColors.primary]) — lets a screen color-code several section cards
  /// (e.g. a "pending" vs. "completed" pairing) without every other
  /// [SectionCard] call site needing to opt in.
  final Color? accentColor;

  /// When true, [child] is wrapped in an [Expanded] so it fills whatever
  /// height this card is given by its own ancestor (e.g. a page-level
  /// `Expanded`) instead of sizing to its natural/intrinsic height. Needed
  /// when [child] itself contains a bounded-height `ListView.builder` that
  /// must know how tall it's allowed to be to build lazily. Every existing
  /// call site leaves this `false` — natural-height behavior is unchanged.
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return AppCard(padding: padding ?? const EdgeInsets.all(AppDimensions.spacingMd), child: child);
    }

    final Color accent = accentColor ?? AppColors.primary;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingXs),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: AppDimensions.iconSm, color: accent),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (expandChild)
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AppDimensions.spacingMd),
                child: child,
              ),
            )
          else
            Padding(
              padding: padding ?? const EdgeInsets.all(AppDimensions.spacingMd),
              child: child,
            ),
        ],
      ),
    );
  }
}
