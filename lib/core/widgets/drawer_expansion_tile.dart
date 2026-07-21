import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// An expandable navigation-drawer group (e.g. "Reports") hosting a list of
/// [DrawerTile] children.
class DrawerExpansionTile extends StatelessWidget {
  const DrawerExpansionTile({
    required this.icon,
    required this.label,
    required this.children,
    super.key,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String label;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: colors.onSurfaceVariant),
          title: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          childrenPadding: EdgeInsets.zero,
          children: children,
        ),
      ),
    );
  }
}
