import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String url;
  final double size;

  const AppAvatar({
    super.key,
    required this.url,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxShape.cover,
        ),
      ),
    );
  }
}
