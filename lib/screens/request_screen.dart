import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../widgets/auth_editor.dart';
import '../widgets/body_editor.dart';
import '../widgets/kv_editor.dart';
import '../widgets/response_viewer.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestEditorProvider);
    final notifier = ref.read(requestEditorProvider.notifier);
    final theme = Theme.of(context);

    final methodColors = {
      'GET': const Color(0xFF61AFFE),
      'POST': const Color(0xFF49CC90),
      'PUT': const Color(0xFFFCA130),
      'PATCH': const Color(0xFF50E3C2),
      'DELETE': const Color(0xFFF93E3E),
      'HEAD': const Color(0xFF9012FE),
      'OPTIONS': const Color(0xFF0D5AA7),
    };

    final methodColor = methodColors[state.method] ?? Colors.grey;

    final tabs = ['Params', 'Headers', 'Body', 'Auth'];
    final tabIcons = const [
      Icons.merge_type,
      Icons.list,
      Icons.description_outlined,
      Icons.lock_outline,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.method.isNotEmpty ? state.method : 'Request',
          style: TextStyle(color: methodColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Send',
              onPressed: () => notifier.sendRequest(),
            ),
        ],
      ),
      body: Column(
        children: [
          _UrlBar(
            controller: _urlController,
            method: state.method,
            methodColor: methodColor,
            onMethodChanged: notifier.setMethod,
            onUrlChanged: notifier.setUrl,
            onSend: notifier.sendRequest,
            isLoading: state.isLoading,
          ),
          const Divider(height: 1),
          Container(
            color: theme.colorScheme.surfaceContainerLow,
            child: Row(
              children: List.generate(tabs.length, (i) {
                final selected = state.selectedTab == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => notifier.setTab(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected ? theme.colorScheme.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabIcons[i],
                            size: 16,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tabs[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: state.selectedTab,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: KVEditor(
                    entries: state.queryParams,
                    onChanged: notifier.setQueryParams,
                    keyHint: 'Query param',
                    valueHint: 'Value',
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: KVEditor(
                    entries: state.headers,
                    onChanged: notifier.setHeaders,
                    keyHint: 'Header name',
                    valueHint: 'Header value',
                  ),
                ),
                BodyEditor(state: state, notifier: notifier),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: AuthEditor(state: state, notifier: notifier),
                ),
              ],
            ),
          ),
          if (state.response != null)
            ResponseViewer(
              response: state.response!,
              error: state.error,
            ),
        ],
      ),
    );
  }

}

class _UrlBar extends StatelessWidget {
  final TextEditingController controller;
  final String method;
  final Color methodColor;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String> onUrlChanged;
  final VoidCallback onSend;
  final bool isLoading;

  const _UrlBar({
    required this.controller,
    required this.method,
    required this.methodColor,
    required this.onMethodChanged,
    required this.onUrlChanged,
    required this.onSend,
    required this.isLoading,
  });

  static const _methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: methodColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: methodColor.withAlpha(80)),
              ),
              child: DropdownButton<String>(
                value: method,
                style: TextStyle(
                  color: methodColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                items: _methods.map((m) {
                  final c = {
                    'GET': const Color(0xFF61AFFE),
                    'POST': const Color(0xFF49CC90),
                    'PUT': const Color(0xFFFCA130),
                    'PATCH': const Color(0xFF50E3C2),
                    'DELETE': const Color(0xFFF93E3E),
                    'HEAD': const Color(0xFF9012FE),
                    'OPTIONS': const Color(0xFF0D5AA7),
                  }[m]!;
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onMethodChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'https://api.example.com/endpoint',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              onChanged: onUrlChanged,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Send',
            onPressed: isLoading ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: methodColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
