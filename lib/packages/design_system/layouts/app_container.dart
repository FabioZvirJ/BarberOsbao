import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  const AppContainer({
    super.key,
    required this.child,
    this.maxWidth = 1800.0,
    this.padding,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);

    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : (isTablet ? 24.0 : 32.0),
          vertical: isMobile ? 16.0 : 28.0,
        );

    Widget content = Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        width: double.infinity,
        padding: effectivePadding,
        child: child,
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    return content;
  }
}
