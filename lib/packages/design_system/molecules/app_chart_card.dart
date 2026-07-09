import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';

class AppChartDataPoint {
  final String label;
  final double value;

  AppChartDataPoint({required this.label, required this.value});
}

class AppChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<AppChartDataPoint> data;
  final Color chartColor;
  final String valuePrefix;

  const AppChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.chartColor = ThemeColors.primary,
    this.valuePrefix = 'R\$ ',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find max value for scaling
    final maxValue = data.map((d) => d.value).fold(0.0, (max, val) => val > max ? val : max);
    final total = data.map((d) => d.value).fold(0.0, (sum, val) => sum + val);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white60 : Colors.black54,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chartColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: $valuePrefix${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: chartColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _LineChartPainter(
                    dataPoints: data,
                    maxValue: maxValue > 0 ? maxValue : 1.0,
                    chartColor: chartColor,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((d) => Text(
              d.label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AppChartDataPoint> dataPoints;
  final double maxValue;
  final Color chartColor;
  final bool isDark;

  _LineChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.chartColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final stepX = width / (dataPoints.length - 1);

    // Draw horizontal grid lines (subtle)
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final y = height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      // y is inverted in flutter canvas
      final pct = dataPoints[i].value / maxValue;
      final y = height - (pct * height * 0.85 + height * 0.07);
      points.add(Offset(x, y));
    }

    // Create Path for line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    // Smooth line using bezier/cubics
    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    // Paint for gradient fill under the line
    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          chartColor.withOpacity(0.25),
          chartColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Paint for line
    final linePaint = Paint()
      ..color = chartColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw glowing circles at data points
    final dotPaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.fill;
    
    final dotBorderPaint = Paint()
      ..color = isDark ? ThemeColors.darkSurface : Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var p in points) {
      canvas.drawCircle(p, 5.0, dotPaint);
      canvas.drawCircle(p, 5.0, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.chartColor != chartColor ||
        oldDelegate.isDark != isDark;
  }
}
