import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';

class AppChartDataPoint {
  final String label;
  final double value;

  AppChartDataPoint({required this.label, required this.value});
}

class AppChartCard extends StatefulWidget {
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
  State<AppChartCard> createState() => _AppChartCardState();
}

class _AppChartCardState extends State<AppChartCard> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find max value for scaling
    final maxValue = widget.data
        .map((d) => d.value)
        .fold(0.0, (max, val) => val > max ? val : max);
    final total = widget.data
        .map((d) => d.value)
        .fold(0.0, (sum, val) => sum + val);

    final hoveredPoint = (_hoveredIndex != null &&
            _hoveredIndex! >= 0 &&
            _hoveredIndex! < widget.data.length)
        ? widget.data[_hoveredIndex!]
        : null;

    final formattedHoverValue = hoveredPoint != null
        ? (widget.valuePrefix.contains('R\$')
            ? AppFormatters.formatCurrency(hoveredPoint.value)
            : '${widget.valuePrefix}${AppFormatters.formatNumber(hoveredPoint.value)}')
        : '';

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hoveredPoint != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.chartColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.chartColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: widget.chartColor),
                      const SizedBox(width: 6),
                      Text(
                        '${hoveredPoint.label}: $formattedHoverValue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.chartColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.chartColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.valuePrefix.contains('R\$')
                        ? 'Total: ${AppFormatters.formatCurrency(total)}'
                        : 'Total: ${widget.valuePrefix}${AppFormatters.formatNumber(total)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.chartColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final count = widget.data.length;
                final stepX = count > 1 ? width / (count - 1) : width;

                return MouseRegion(
                  hitTestBehavior: HitTestBehavior.opaque,
                  onHover: (event) {
                    if (count > 0) {
                      final idx = (event.localPosition.dx / stepX)
                          .round()
                          .clamp(0, count - 1);
                      if (_hoveredIndex != idx) {
                        setState(() => _hoveredIndex = idx);
                      }
                    }
                  },
                  onExit: (_) {
                    if (_hoveredIndex != null) {
                      setState(() => _hoveredIndex = null);
                    }
                  },
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _LineChartPainter(
                          dataPoints: widget.data,
                          maxValue: maxValue > 0 ? maxValue : 1.0,
                          chartColor: widget.chartColor,
                          isDark: isDark,
                          hoveredIndex: _hoveredIndex,
                        ),
                      ),
                      if (hoveredPoint != null && count > 1)
                        Positioned(
                          left: (_hoveredIndex! * stepX - 45).clamp(
                            0.0,
                            constraints.maxWidth - 90,
                          ),
                          top: 4,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? ThemeColors.darkSurface
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color:
                                      widget.chartColor.withValues(alpha: 0.8),
                                ),
                              ),
                              child: Text(
                                formattedHoverValue,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.data.asMap().entries.map((entry) {
              final idx = entry.key;
              final d = entry.value;
              final isHovered = _hoveredIndex == idx;
              return Text(
                d.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                  color: isHovered
                      ? widget.chartColor
                      : (isDark ? Colors.white30 : Colors.grey.shade400),
                ),
              );
            }).toList(),
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
  final int? hoveredIndex;

  _LineChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.chartColor,
    required this.isDark,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final stepX = dataPoints.length > 1 ? width / (dataPoints.length - 1) : width;

    // Draw horizontal grid lines (subtle)
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final y = height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final pct = dataPoints[i].value / maxValue;
      final y = height - (pct * height * 0.85 + height * 0.07);
      points.add(Offset(x, y));
    }

    // Create Path for line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
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
          chartColor.withValues(alpha: 0.25),
          chartColor.withValues(alpha: 0.0),
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

    // If a point is hovered, draw a subtle vertical guideline
    if (hoveredIndex != null &&
        hoveredIndex! >= 0 &&
        hoveredIndex! < points.length) {
      final hoverPoint = points[hoveredIndex!];
      final guidePaint = Paint()
        ..color = chartColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(hoverPoint.dx, 0),
        Offset(hoverPoint.dx, height),
        guidePaint,
      );
    }

    // Draw glowing circles at data points
    final dotPaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = isDark ? ThemeColors.darkSurface : Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final isHovered = hoveredIndex == i;
      final radius = isHovered ? 7.0 : 5.0;

      if (isHovered) {
        // Outer halo
        final haloPaint = Paint()
          ..color = chartColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 12.0, haloPaint);
      }

      canvas.drawCircle(p, radius, dotPaint);
      canvas.drawCircle(p, radius, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.chartColor != chartColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
