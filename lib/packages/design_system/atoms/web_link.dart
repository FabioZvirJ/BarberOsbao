import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebLinkButton extends StatelessWidget {
  final String url;
  final String label;
  final ButtonStyle? style;

  const WebLinkButton({super.key, required this.url, this.label = 'Versão Web', this.style});

  Future<void> _openUrl() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _openUrl,
      style: style,
      child: Text(label),
    );
  }
}
