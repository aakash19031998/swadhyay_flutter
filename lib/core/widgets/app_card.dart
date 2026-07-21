import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Standard content card: consistent padding, radius and elevation so
/// dashboard tiles, list rows and report rows share one visual language.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppDimensions.spacingMd),
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: child);

    return Card(
      margin: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: content,
            ),
    );
  }
}
