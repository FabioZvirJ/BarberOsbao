import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const AppContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200.0,
    this.padding = const EdgeInsets.all(32.0),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
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
