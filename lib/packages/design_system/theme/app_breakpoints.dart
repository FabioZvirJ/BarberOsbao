import 'package:flutter/material.dart';

/// Market-standard breakpoints following Material Design 3 guidelines.
/// - Desktop  : width >= 960px  (persistent sidebar, full tables)
/// - Tablet   : 600px-960px     (drawer sidebar, 2-column card grid)
/// - Mobile   : < 600px         (drawer sidebar, single-column list)
abstract class AppBreakpoints {
  const AppBreakpoints._();

  static const double desktop = 960.0;
  static const double tablet = 600.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  /// Returns the number of grid columns:
  /// desktop -> [desktopCols], tablet -> [tabletCols], mobile -> [mobileCols]
  static int gridColumns(
    BuildContext context, {
    int desktopCols = 4,
    int tabletCols = 2,
    int mobileCols = 1,
  }) {
    if (isDesktop(context)) return desktopCols;
    if (isTablet(context)) return tabletCols;
    return mobileCols;
  }
}