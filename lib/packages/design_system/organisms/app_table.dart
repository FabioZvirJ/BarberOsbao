import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';

class AppTableColumn {
  final String label;
  final double? width;

  AppTableColumn({required this.label, this.width});
}

class AppTableRow {
  final List<Widget> cells;
  final VoidCallback? onTap;

  AppTableRow({required this.cells, this.onTap});
}

class AppTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  /// Minimum width for the table content when horizontal scroll is active.
  /// Defaults to 700. Increase for tables with many columns.
  final double minWidth;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AppBreakpoints.isDesktop(context);

    final tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkSurface.withValues(alpha: 0.5) : Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(ThemeColors.radius),
              topRight: Radius.circular(ThemeColors.radius),
            ),
            border: Border.all(color: isDark ? ThemeColors.darkBorder : Colors.grey.shade100, width: 1.5),
          ),
          child: Row(
            children: columns.map((col) {
              final cellWidget = Text(
                col.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              );

              if (col.width != null) {
                return SizedBox(width: col.width, child: cellWidget);
              }
              return Expanded(child: cellWidget);
            }).toList(),
          ),
        ),

        // Table Rows
        Container(
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(ThemeColors.radius),
              bottomRight: Radius.circular(ThemeColors.radius),
            ),
            border: Border(
              left: BorderSide(color: isDark ? ThemeColors.darkBorder : Colors.grey.shade100, width: 1.5),
              right: BorderSide(color: isDark ? ThemeColors.darkBorder : Colors.grey.shade100, width: 1.5),
              bottom: BorderSide(color: isDark ? ThemeColors.darkBorder : Colors.grey.shade100, width: 1.5),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? ThemeColors.darkBorder : Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final row = rows[index];
              return InkWell(
                onTap: row.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: List.generate(row.cells.length, (cellIdx) {
                      final colWidth = columns[cellIdx].width;
                      final cellWidget = row.cells[cellIdx];

                      if (colWidth != null) {
                        return SizedBox(width: colWidth, child: cellWidget);
                      }
                      return Expanded(child: cellWidget);
                    }),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    // On desktop show the table full-width; on tablet/mobile wrap in horizontal scroll.
    if (isDesktop) return tableContent;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: tableContent,
      ),
    );
  }
}
