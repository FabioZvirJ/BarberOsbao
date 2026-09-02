import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? icon;
  final String? trendText;
  final bool positiveTrend;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.trendText,
    this.positiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              ?icon,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (trendText != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    (positiveTrend ? ThemeColors.success : ThemeColors.danger)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    positiveTrend ? Icons.trending_up : Icons.trending_down,
                    size: 13,
                    color: positiveTrend
                        ? ThemeColors.success
                        : ThemeColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: positiveTrend
                          ? ThemeColors.success
                          : ThemeColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
