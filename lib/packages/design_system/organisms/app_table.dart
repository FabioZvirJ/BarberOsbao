import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppTableColumn {
  final String label;
  final double? width;
  final int flex;
  final Alignment alignment;

  AppTableColumn({
    required this.label,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });
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

    final tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(ThemeColors.radius),
              topRight: Radius.circular(ThemeColors.radius),
            ),
            border: Border.all(
              color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
          child: Row(
            children: columns.map((col) {
              final cellWidget = Text(
                col.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white60 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              );

              if (col.width != null) {
                return SizedBox(
                  width: col.width,
                  child: Align(alignment: col.alignment, child: cellWidget),
                );
              }
              return Expanded(
                flex: col.flex,
                child: Align(alignment: col.alignment, child: cellWidget),
              );
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
              left: BorderSide(
                color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                width: 1.0,
              ),
              right: BorderSide(
                color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                width: 1.0,
              ),
              bottom: BorderSide(
                color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                width: 1.0,
              ),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final row = rows[index];
              return InkWell(
                onTap: row.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: List.generate(row.cells.length, (cellIdx) {
                      final col = columns[cellIdx];
                      final cellWidget = row.cells[cellIdx];

                      if (col.width != null) {
                        return SizedBox(
                          width: col.width,
                          child: Align(alignment: col.alignment, child: cellWidget),
                        );
                      }
                      return Expanded(
                        flex: col.flex,
                        child: Align(alignment: col.alignment, child: cellWidget),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveWidth =
            availableWidth > minWidth ? availableWidth : minWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: tableContent,
          ),
        );
      },
    );
  }
}
