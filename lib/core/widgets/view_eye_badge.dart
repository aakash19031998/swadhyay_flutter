import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// The solid, drop-shadowed eye badge used everywhere a bag image or Bag
/// No. is tappable to open a media viewer or detail screen — the Bag List
/// card's own image overlay, its Bag No. row, and the Bag Detail screen's
/// image preview all use this exact same badge so the "tap to view"
/// affordance reads identically across every screen.
class ViewEyeBadge extends StatelessWidget {
  const ViewEyeBadge({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.visibility_rounded,
        color: AppColors.onPrimary,
        size: AppDimensions.iconSm,
      ),
    );
  }
}
