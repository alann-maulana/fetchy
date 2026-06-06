import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/spacing.dart';
import '../config/typography.dart';
import '../models/api_request.dart';
import '../providers/request_provider.dart';
import '../providers/storage_provider.dart';
import '../services/curl_parser.dart';
import '../widgets/auth_editor.dart';
import '../widgets/body_editor.dart';
import '../widgets/kv_editor.dart';
import '../widgets/response_viewer.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _urlController;
  String? _loadedRequestId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(requestEditorProvider.notifier).setTab(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequest();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequest();
    });
  }

  void _loadRequest() {
    final extra = GoRouterState.of(context).extra;
    if (extra is ApiRequest && extra.id != _loadedRequestId) {
      _loadedRequestId = extra.id;
      ref.read(requestEditorProvider.notifier).loadRequest(extra);
      _urlController.text = extra.url;
    } else if (extra == null && mounted) {
      _loadedRequestId = null;
      ref.read(requestEditorProvider.notifier).reset();
      _urlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestEditorProvider);
    final notifier = ref.read(requestEditorProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final method = state.method;
    final mColor = method.methodColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
              decoration: BoxDecoration(
                color: mColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Spacing.chipRadius),
                border: Border.all(color: mColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                method,
                style: AppTextStyles.methodBadge.copyWith(color: mColor),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                state.url.isNotEmpty ? state.url : 'Request',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
          else ...[
            IconButton(
              icon: const Icon(Icons.content_paste_go),
              tooltip: 'Import cURL',
              onPressed: () => _showImportCurlDialog(notifier),
            ),
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save',
              onPressed: () => _showSaveDialog(state, notifier),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Send',
              onPressed: _sendRequest,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // URL bar
          _UrlBar(
            controller: _urlController,
            method: method,
            methodColor: mColor,
            onMethodChanged: notifier.setMethod,
            onUrlChanged: (v) {
              _urlController.text = v;
              _urlController.selection = TextSelection.collapsed(offset: v.length);
              notifier.setUrl(v);
            },
            onSend: _sendRequest,
            isLoading: state.isLoading,
          ),
          const Divider(height: 1),

          // Tabs
          Container(
            color: colors.surfaceContainerLow,
            child: TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              unselectedLabelColor: colors.onSurfaceVariant,
              indicatorColor: colors.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: 'Params', icon: Icon(Icons.merge_type, size: 16)),
                Tab(text: 'Headers', icon: Icon(Icons.list, size: 16)),
                Tab(text: 'Body', icon: Icon(Icons.description_outlined, size: 16)),
                Tab(text: 'Auth', icon: Icon(Icons.lock_outline, size: 16)),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: KVEditor(
                    entries: state.queryParams,
                    onChanged: notifier.setQueryParams,
                    keyHint: 'Query param',
                    valueHint: 'Value',
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: KVEditor(
                    entries: state.headers,
                    onChanged: notifier.setHeaders,
                    keyHint: 'Header name',
                    valueHint: 'Header value',
                  ),
                ),
                BodyEditor(state: state, notifier: notifier),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: AuthEditor(state: state, notifier: notifier),
                ),
              ],
            ),
          ),

          // Response
          if (state.response != null)
            ResponseViewer(
              response: state.response!,
              error: state.error,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  void _showImportCurlDialog(RequestEditorNotifier notifier) {
    final curlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from cURL'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paste a cURL command below to populate the request fields.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: curlController,
                maxLines: 8,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'curl https://api.example.com/endpoint \\\n  -H "Authorization: Bearer token" \\\n  -d \'{"key":"value"}\'',
                  border: OutlineInputBorder(),
                ),
                style: AppTextStyles.code,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final raw = curlController.text.trim();
              if (raw.isEmpty) return;
              final result = CurlParser.parse(raw);
              if (result.url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not parse cURL command')),
                );
                return;
              }
              final headers = result.headers.entries
                  .map((e) => KVEntry(key: e.key, value: e.value))
                  .toList();
              _urlController.text = result.url;
              notifier.setMethod(result.method);
              notifier.setUrl(result.url);
              notifier.setHeaders(headers);
              notifier.setBodyType(result.body != null ? 'raw' : 'none');
              if (result.body != null) {
                notifier.setBodyContent(result.body!);
              }
              if (result.authUsername != null) {
                notifier.setAuthType('basic');
                notifier.setAuthUsername(result.authUsername!);
                notifier.setAuthPassword(result.authPassword ?? '');
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('cURL imported successfully')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _sendRequest() {
    final activeEnv = ref.read(environmentsProvider.notifier).active;
    ref.read(requestEditorProvider.notifier).sendRequest(activeEnv: activeEnv);
  }

  void _showSaveDialog(RequestEditorState state, RequestEditorNotifier notifier) {
    if (state.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to save — URL is empty')),
      );
      return;
    }

    final isEditing = _loadedRequestId != null;
    final existingRequest = isEditing
        ? ref.read(savedRequestsProvider).where((r) => r.id == _loadedRequestId).firstOrNull
        : null;

    if (isEditing) {
      final request = notifier.buildRequest(
        name: existingRequest?.name ?? '${state.method} ${state.url}',
        collectionId: existingRequest?.collectionId,
      );
      final requestWithId = request.copyWith(id: _loadedRequestId);
      ref.read(savedRequestsProvider.notifier).save(requestWithId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated "${existingRequest?.name ?? request.name}"')),
      );
      return;
    }

    final allCollections = ref.read(collectionsProvider);
    final nameController = TextEditingController();
    String? selectedCollectionId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Save Request'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: state.method.isNotEmpty
                        ? '${state.method} ${state.url}'
                        : 'My Request',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                if (allCollections.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedCollectionId,
                    decoration: const InputDecoration(
                      hintText: 'Collection (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder_outlined, size: 20),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None — save as standalone'),
                      ),
                      ...allCollections.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          )),
                    ],
                    onChanged: (v) => setDialogState(() => selectedCollectionId = v),
                  ),
                ] else ...[
                  Text(
                    'No collections yet. Save will create a standalone request.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim().isNotEmpty
                    ? nameController.text.trim()
                    : '${state.method} ${state.url}';
                final request = notifier.buildRequest(
                  name: name,
                  collectionId: selectedCollectionId,
                );
                ref.read(savedRequestsProvider.notifier).save(request);
                if (selectedCollectionId != null) {
                  ref
                      .read(collectionsProvider.notifier)
                      .addRequest(selectedCollectionId!, request.id);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved "$name"')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.xs, Spacing.sm),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 2),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Spacing.inputRadius),
                border: Border.all(color: methodColor.withValues(alpha: 0.25)),
              ),
              child: DropdownButton<String>(
                value: method,
                style: TextStyle(
                  color: methodColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
                underline: const SizedBox.shrink(),
                items: _methods.map((m) {
                  final c = m.methodColor;
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m,
                        style: TextStyle(
                            color: c,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.3)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onMethodChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Spacing.inputRadius),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'https://api.example.com/endpoint',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                  border: InputBorder.none,
                  filled: false,
                ),
                style: AppTextStyles.code.copyWith(fontSize: 14),
                onChanged: onUrlChanged,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          IconButton.filled(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Send',
            onPressed: isLoading ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: methodColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.inputRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
