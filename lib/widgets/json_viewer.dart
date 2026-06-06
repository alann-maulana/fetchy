import 'dart:convert';
import 'package:flutter/material.dart';

class JsonViewer extends StatelessWidget {
  final String body;

  const JsonViewer({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    try {
      final parsed = jsonDecode(body);
      final pretty = const JsonEncoder.withIndent('  ').convert(parsed);
      return _buildCodeView(context, pretty);
    } catch (_) {
      return _buildCodeView(context, body);
    }
  }

  Widget _buildCodeView(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
