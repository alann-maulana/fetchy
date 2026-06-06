import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../config/spacing.dart';
import '../config/typography.dart';
import '../models/api_request.dart';
import '../models/collection.dart';
import '../providers/storage_provider.dart';
import '../services/postman_service.dart';
import '../widgets/empty_state.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  ConsumerState<CollectionDetailScreen> createState() =>
      _CollectionDetailScreenState();
}

class _CollectionDetailScreenState
    extends ConsumerState<CollectionDetailScreen> {
  final _postmanService = PostmanService();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);
    final collection =
        collections.where((c) => c.id == widget.collectionId).firstOrNull;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: const Center(child: Text('Collection not found')),
      );
    }

    final allRequests = ref.watch(savedRequestsProvider);
    final colRequests = collection.requestIds
        .map((id) => allRequests.where((r) => r.id == id).firstOrNull)
        .whereType<ApiRequest>()
        .toList();

    if (!_isEditing) {
      _nameController.text = collection.name;
      _descController.text = collection.description ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(border: InputBorder.none),
              )
            : Text(collection.name),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEdit,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => _handleAction(v, collection),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.file_upload_outlined, size: 18),
                      title: Text('Export'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )),
                const PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.file_download_outlined, size: 18),
                      title: Text('Import requests'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )),
                const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, size: 18),
                      title: Text('Delete'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            )
          else if (collection.description != null &&
              collection.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
              child: Text(
                collection.description!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.sm),
            child: Row(
              children: [
                Icon(Icons.api, size: 16, color: colors.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  colRequests.length == 1
                      ? '1 request'
                      : '${colRequests.length} requests',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Request list
          Expanded(
            child: colRequests.isEmpty
                ? EmptyState(
                    icon: Icons.api_outlined,
                    title: 'No requests yet',
                    subtitle: 'Add API requests to this collection',
                    action: FilledButton.tonalIcon(
                      onPressed: () => context.push('/request'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Request'),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: Spacing.sm, bottom: 80),
                    itemCount: colRequests.length,
                    itemBuilder: (_, i) {
                      final req = colRequests[i];
                      final method = req.method.toUpperCase();
                      final mColor = method.methodColor;
                      return Card(
                        margin: EdgeInsets.fromLTRB(
                            Spacing.lg, Spacing.xs, Spacing.lg, Spacing.xs),
                        child: InkWell(
                          onTap: () =>
                              context.push('/request', extra: req),
                          borderRadius:
                              BorderRadius.circular(Spacing.cardRadius),
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.md),
                            child: Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(minWidth: 44),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Spacing.sm, vertical: Spacing.xxs),
                                  decoration: BoxDecoration(
                                    color: mColor.withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(Spacing.chipRadius),
                                    border: Border.all(
                                        color: mColor.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    method,
                                    style: AppTextStyles.methodBadge
                                        .copyWith(color: mColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: Spacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(req.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: Spacing.xxs),
                                      Text(req.url,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.codeSmall
                                              .copyWith(
                                                  color:
                                                      colors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  onPressed: () =>
                                      _removeRequest(collection, req.id),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/request'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  void _saveEdit() {
    ref
        .read(collectionsProvider.notifier)
        .update(widget.collectionId,
            name: _nameController.text, description: _descController.text);
    setState(() => _isEditing = false);
  }

  void _handleAction(String action, Collection collection) {
    switch (action) {
      case 'export':
        _exportCollection(collection);
      case 'import':
        _showImportDialog(collection);
      case 'delete':
        _deleteCollection(collection);
    }
  }

  void _exportCollection(Collection collection) {
    final allRequests = ref.read(savedRequestsProvider);
    final json = _postmanService.exportCollection(collection, allRequests);
    final pretty = const JsonEncoder.withIndent('  ').convert(json);
    Clipboard.setData(ClipboardData(text: pretty));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collection exported to clipboard')),
    );
  }

  void _showImportDialog(Collection collection) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Postman Collection'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste Postman Collection v2.1 JSON here...',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              _importRequests(collection, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _importRequests(Collection collection, String jsonText) {
    try {
      final data = jsonDecode(jsonText) as Map<String, dynamic>;
      final result = _postmanService.importCollection(data);
      final notifier = ref.read(collectionsProvider.notifier);
      for (final req in result.requests) {
        ref.read(savedRequestsProvider.notifier).save(req);
        notifier.addRequest(collection.id, req.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${result.requests.length} requests')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  void _deleteCollection(Collection collection) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Delete "${collection.name}" and its ${collection.requestIds.length} requests?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(collectionsProvider.notifier).delete(collection.id);
              Navigator.pop(ctx);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _removeRequest(Collection collection, String requestId) {
    ref
        .read(collectionsProvider.notifier)
        .removeRequest(collection.id, requestId);
  }
}
