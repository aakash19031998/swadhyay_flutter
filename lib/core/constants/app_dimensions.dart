/// Centralized spacing, radius and sizing tokens.
///
/// No screen or widget should hardcode a numeric dimension — every
/// spacing/radius/size value used across the app must be sourced from here
/// so the design language stays consistent and can be tuned in one place.
class AppDimensions {
  const AppDimensions._();

  // Spacing scale.
  static const double spacingXxs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Border radius.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // Form standards.
  static const double formFieldRadius = radiusMd;
  static const double formFieldPadding = spacingMd;
  static const double formFieldHeight = 56;

  // Elevation.
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;

  // Icon sizes.
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Avatar / profile sizes.
  static const double avatarSm = 36;
  static const double avatarMd = 56;
  static const double avatarLg = 88;

  // Bag list. bagThumbnailSize is the media-viewer filmstrip thumbnail;
  // bagCardImageHeight sizes the grid card's photo — the card's overall
  // height is intrinsic/content-driven (see ReportListScaffold's masonry
  // mode), not a fixed constant.
  static const double bagThumbnailSize = 76;
  static const double bagCardImageHeight = 170;

  // Bag detail.
  static const double bagDetailSidebarWidth = 190;
  static const double bagDetailTabViewHeight = 420;
  static const double bagDetailSegmentedTabBarHeight = 40;

  // Profile.
  static const double profileHeroAvatarSize = 130;
  static const double profileGaugeSize = 110;

  // Timing report chart. Plot height is computed at runtime from the
  // available screen space (full-screen chart) rather than fixed, clamped
  // to this minimum so it never collapses on a very short viewport.
  static const double timingChartMinPlotHeight = 160;
  static const double timingChartDayLabelHeight = 28;
  static const double timingChartLabelHeadroom = 18;
  static const double timingChartBarWidth = 14;
  static const double timingChartBarGap = 3;
  static const double timingChartDayColumnGap = 10;
  static const double timingChartYAxisWidth = 40;

  // PIN input.
  static const double pinBoxSize = 56;
  static const double pinBoxSpacing = spacingMd;
  static const int pinLength = 4;

  // Drawer. Two fractions so width actually scales with screen size at both
  // ends instead of sitting pinned at drawerMinWidth for every phone.
  static const double drawerPhoneWidthFraction = 0.82;
  static const double drawerTabletWidthFraction = 0.34;
  static const double drawerMinWidth = 300;
  static const double drawerMaxWidth = 440;

  // AppBar.
  static const double appBarHeight = 64;

  // Dialogs.
  static const double dialogMaxWidth = 320;

  // Buttons.
  static const double buttonHeight = 52;
  static const double buttonMinWidth = 120;

  // Breakpoints (logical pixels, width).
  static const double breakpointPhone = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;

  // Max content width for large screens so content doesn't stretch edge to edge.
  static const double maxContentWidth = 720;
}
