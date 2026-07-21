import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Shorthand accessors so widgets don't repeat `Theme.of(context)...` and
/// `MediaQuery.sizeOf(context)...` boilerplate everywhere.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isTabletOrLarger => Responsive.isTabletOrLarger(this);

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
}
