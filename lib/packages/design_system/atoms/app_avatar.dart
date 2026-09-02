import 'dart:convert';
import 'package:flutter/material.dart';

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

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
        border: Border.all(color: Colors.white24, width: 1.5),
        image: provider != null
            ? DecorationImage(image: provider, fit: BoxFit.cover)
            : null,
      ),
      child: provider == null
          ? Center(
              child: name != null && name!.trim().isNotEmpty
                  ? Text(
                      name!.trim()[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.45,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: size * 0.55,
                      color: Colors.white70,
                    ),
            )
          : null,
    );
  }
}
