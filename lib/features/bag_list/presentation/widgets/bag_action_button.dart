import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Elevated pill action button for a bag's Start/Pause/Resume/Done —
/// solid brand color, drop shadow, and the icon set inside its own
/// translucent circle for the "3D" look, matching [AppButton]'s filled
/// style but compact enough for a card footer.
///
/// Shared by [BagListItem] (`_StatusRow`) and the Bag Detail screen's top
/// bar so both render the exact same widget for these actions — not just a
/// visually-similar copy — guaranteeing there's never a drift between the
/// two screens' colors, icons, spacing, or shadow.
class BagActionButton extends StatelessWidget {
  const BagActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Scales the whole pill down (never up) so the longest label —
    // "Completed" — can't overflow a narrower width it's given when laid
    // out alongside other content.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.onPrimary, size: AppDimensions.iconMd),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
