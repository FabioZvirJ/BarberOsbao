import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({
    super.key,
    required this.label,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Selecionar data';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime.now(),
              lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: ThemeColors.primary,
                      onPrimary: isDark ? Colors.black : Colors.white,
                      onSurface: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          borderRadius: BorderRadius.circular(ThemeColors.radius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? ThemeColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(ThemeColors.radius),
              border: Border.all(
                color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedDate != null
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark ? Colors.white30 : Colors.grey.shade400),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: ThemeColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
