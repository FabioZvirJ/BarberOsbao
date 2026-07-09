import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppSelectOption<T> {
  final T value;
  final String label;

  AppSelectOption({required this.value, required this.label});
}

class AppSelect<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? placeholder;

  const AppSelect({
    super.key,
    required this.label,
    this.value,
    required this.options,
    required this.onChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? ThemeColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(ThemeColors.radius),
            border: Border.all(
              color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: placeholder != null
                  ? Text(
                      placeholder!,
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontSize: 14),
                    )
                  : null,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: ThemeColors.primary),
              dropdownColor: isDark ? ThemeColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(ThemeColors.radius),
              items: options.map((opt) {
                return DropdownMenuItem<T>(
                  value: opt.value,
                  child: Text(
                    opt.label,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
