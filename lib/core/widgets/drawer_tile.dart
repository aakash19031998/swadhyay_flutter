import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// A single, tappable navigation-drawer row.
class DrawerTile extends StatelessWidget {
  const DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.selected = false,
    this.indent = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color color = selected ? colors.primary : colors.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingSm + indent,
        right: AppDimensions.spacingSm,
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
        selected: selected,
        selectedTileColor: colors.primaryContainer.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
        onTap: onTap,
      ),
    );
  }
}
