import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppAvatar extends StatelessWidget {
  final String url;
  final double size;
  final String? name;

  const AppAvatar({super.key, required this.url, this.size = 48.0, this.name});

  ImageProvider? _getImageProvider() {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = trimmed.substring(commaIndex + 1);
          return MemoryImage(base64Decode(base64Str));
        }
      } catch (_) {
        return null;
      }
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _getImageProvider();
    final initials = AppFormatters.getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: provider == null
            ? ThemeColors.primary.withValues(alpha: 0.2)
            : Colors.grey.shade800,
        border: Border.all(
          color: provider == null
              ? ThemeColors.primary.withValues(alpha: 0.5)
              : Colors.white24,
          width: 1.5,
        ),
        image: provider != null
            ? DecorationImage(
                image: provider,
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              )
            : null,
      ),
      child: provider == null
          ? Center(
              child: initials != '?'
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontSize: size * 0.38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: size * 0.55,
                      color: ThemeColors.primary,
                    ),
            )
          : null,
    );
  }
}

