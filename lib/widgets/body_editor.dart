import 'package:flutter/material.dart';
import '../providers/request_provider.dart';
import 'kv_editor.dart';

class BodyEditor extends StatelessWidget {
  final RequestEditorState state;
  final RequestEditorNotifier notifier;

  const BodyEditor({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final types = ['none', 'raw', 'json', 'form-data', 'x-www-form-urlencoded'];
    final labels = {
      'none': 'None',
      'raw': 'Raw',
      'json': 'JSON',
      'form-data': 'Form Data',
      'x-www-form-urlencoded': 'URL-Encoded',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: types.map((t) {
              final selected = state.bodyType == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(labels[t]!),
                  selected: selected,
                  onSelected: (_) => notifier.setBodyType(t),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        if (state.bodyType == 'raw' || state.bodyType == 'json') ...[
          Expanded(
            child: TextField(
              controller: TextEditingController(text: state.bodyContent)
                ..selection = TextSelection.collapsed(offset: state.bodyContent.length),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: state.bodyType == 'json' ? '{"key": "value"}' : 'Body content...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              onChanged: notifier.setBodyContent,
            ),
          ),
        ] else if (state.bodyType == 'form-data' || state.bodyType == 'x-www-form-urlencoded') ...[
          Expanded(
            child: SingleChildScrollView(
              child: KVEditor(
                entries: state.queryParams,
                onChanged: notifier.setQueryParams,
                keyHint: state.bodyType == 'form-data' ? 'Field' : 'Key',
                valueHint: state.bodyType == 'form-data' ? 'Value' : 'Value',
              ),
            ),
          ),
        ] else ...[
          const Expanded(
            child: Center(child: Text('This request does not have a body')),
          ),
        ],
      ],
    );
  }
}
