import 'package:flutter/material.dart';
import '../config/spacing.dart';
import '../config/typography.dart';
import '../providers/request_provider.dart';

class KVEditor extends StatelessWidget {
  final List<KVEntry> entries;
  final ValueChanged<List<KVEntry>> onChanged;
  final String keyHint;
  final String valueHint;

  const KVEditor({
    super.key,
    required this.entries,
    required this.onChanged,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.md),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm, vertical: Spacing.xxs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Checkbox(
                        value: entries[i].enabled,
                        onChanged: (v) {
                          final updated = List<KVEntry>.from(entries);
                          updated[i] = entries[i].copyWith(enabled: v);
                          onChanged(updated);
                        },
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: entries[i].key)
                          ..selection = TextSelection.collapsed(
                              offset: entries[i].key.length),
                        decoration: InputDecoration(
                          hintText: keyHint,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Spacing.sm, vertical: Spacing.sm),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Spacing.chipRadius)),
                          filled: false,
                        ),
                        style: AppTextStyles.code,
                        onChanged: (v) {
                          final updated = List<KVEntry>.from(entries);
                          updated[i] = entries[i].copyWith(key: v);
                          onChanged(updated);
                        },
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: TextField(
                        controller:
                            TextEditingController(text: entries[i].value)
                              ..selection = TextSelection.collapsed(
                                  offset: entries[i].value.length),
                        decoration: InputDecoration(
                          hintText: valueHint,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Spacing.sm, vertical: Spacing.sm),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(Spacing.chipRadius)),
                          filled: false,
                        ),
                        style: AppTextStyles.code,
                        onChanged: (v) {
                          final updated = List<KVEntry>.from(entries);
                          updated[i] = entries[i].copyWith(value: v);
                          onChanged(updated);
                        },
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        final updated = List<KVEntry>.from(entries)..removeAt(i);
                        onChanged(updated);
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
            onPressed: () => onChanged([...entries, const KVEntry()]),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.md),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
