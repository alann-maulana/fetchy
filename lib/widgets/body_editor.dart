import 'package:flutter/material.dart';
import '../config/spacing.dart';
import '../config/typography.dart';
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
    final colors = Theme.of(context).colorScheme;
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
        Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.sm),
          child: Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: types.map((t) {
              final selected = state.bodyType == t;
              return ChoiceChip(
                label: Text(labels[t]!, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (_) => notifier.setBodyType(t),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.bodyType == 'none'
              ? Center(
                  child: Text(
                    'This request does not have a body',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                )
              : state.bodyType == 'raw' || state.bodyType == 'json'
                  ? Container(
                      margin: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Spacing.md),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: state.bodyContent)
                          ..selection = TextSelection.collapsed(
                              offset: state.bodyContent.length),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: state.bodyType == 'json'
                              ? '{"key": "value"}'
                              : 'Body content...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(Spacing.md),
                          filled: false,
                        ),
                        style: AppTextStyles.code.copyWith(fontSize: 13),
                        onChanged: notifier.setBodyContent,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: KVEditor(
                        entries: state.queryParams,
                        onChanged: notifier.setQueryParams,
                        keyHint:
                            state.bodyType == 'form-data' ? 'Field' : 'Key',
                        valueHint: 'Value',
                      ),
                    ),
        ),
      ],
    );
  }
}
