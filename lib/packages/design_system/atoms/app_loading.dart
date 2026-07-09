import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppLoading extends StatelessWidget {
  final double size;

  const AppLoading({
    super.key,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.primary),
        ),
      ),
    );
  }
}
