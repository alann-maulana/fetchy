import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/spacing.dart';
import '../config/typography.dart';

class JsonViewer extends StatefulWidget {
  final String body;

  const JsonViewer({super.key, required this.body});

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String displayText;
    try {
      final parsed = jsonDecode(widget.body);
      displayText = const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (_) {
      displayText = widget.body;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _collapsed = !_collapsed),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(Spacing.md),
                bottom: _collapsed
                    ? const Radius.circular(Spacing.md)
                    : Radius.zero,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _collapsed ? Icons.chevron_right : Icons.expand_more,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Response JSON',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${displayText.split('\n').length} lines',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(Spacing.md),
              ),
            ),
            child: SelectableText(
              displayText,
              style: AppTextStyles.code.copyWith(fontSize: 13).apply(
                    color: colors.onSurface,
                  ),
            ),
          ),
          crossFadeState: _collapsed
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: 200.ms,
        ),
      ],
    );
  }
}
