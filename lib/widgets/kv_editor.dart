import 'package:flutter/material.dart';
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
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
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
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: entries[i].key)
                      ..selection = TextSelection.collapsed(offset: entries[i].key.length),
                    decoration: InputDecoration(
                      hintText: keyHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                    onChanged: (v) {
                      final updated = List<KVEntry>.from(entries);
                      updated[i] = entries[i].copyWith(key: v);
                      onChanged(updated);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: entries[i].value)
                      ..selection = TextSelection.collapsed(offset: entries[i].value.length),
                    decoration: InputDecoration(
                      hintText: valueHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                    onChanged: (v) {
                      final updated = List<KVEntry>.from(entries);
                      updated[i] = entries[i].copyWith(value: v);
                      onChanged(updated);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    final updated = List<KVEntry>.from(entries)..removeAt(i);
                    onChanged(updated);
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
        TextButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          onPressed: () => onChanged([...entries, const KVEntry()]),
        ),
      ],
    );
  }
}
