import 'package:flutter/widgets.dart';

import '../constants/app_dimensions.dart';

/// Screen-class helpers driven by [LayoutBuilder]/[MediaQuery] width, used
/// instead of fixed widths so every screen adapts across the primary target
/// (Android tablet landscape) and secondary targets (phone, portrait
/// tablet, iPad).
class Responsive {
  const Responsive._();

  static bool isPhone(double width) => width < AppDimensions.breakpointPhone;

  static bool isTablet(double width) =>
      width >= AppDimensions.breakpointPhone && width < AppDimensions.breakpointDesktop;

  static bool isDesktop(double width) => width >= AppDimensions.breakpointDesktop;

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppDimensions.breakpointPhone;

  /// Picks a value based on the current width, falling back progressively:
  /// desktop -> tablet -> phone.
  static T valueForWidth<T>({
    required double width,
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(width)) return desktop ?? tablet ?? phone;
    if (isTablet(width)) return tablet ?? phone;
    return phone;
  }

  /// Number of grid columns appropriate for the given width.
  static int gridColumnsForWidth(double width) {
    if (isDesktop(width)) return 4;
    if (isTablet(width)) return 3;
    return 2;
  }
}
