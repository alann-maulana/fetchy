import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/api_request.dart';
import '../models/collection.dart';
import '../providers/storage_provider.dart';
import '../services/postman_service.dart';

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
    final collection = collections.where((c) => c.id == widget.collectionId).firstOrNull;
    final theme = Theme.of(context);

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: const Center(child: Text('Collection not found')),
      );
    }

    final allRequests = ref.watch(savedRequestsProvider);
    final colRequests =
        collection.requestIds
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
                const PopupMenuItem(value: 'export', child: Text('Export to clipboard')),
                const PopupMenuItem(value: 'import', child: Text('Import requests')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (collection.description != null &&
              collection.description!.isNotEmpty &&
              !_isEditing)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                collection.description!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.api, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${colRequests.length} requests',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: colRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.api_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No requests in this collection',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () => context.push('/request'),
                          icon: const Icon(Icons.add),
                          label: const Text('New Request'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: colRequests.length,
                    itemBuilder: (_, i) {
                      final req = colRequests[i];
                      final methodColor = _methodColor(req.method);
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: methodColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: methodColor.withAlpha(80)),
                          ),
                          child: Text(
                            req.method,
                            style: TextStyle(
                              color: methodColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        title: Text(req.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(req.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontFamily: 'monospace')),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _removeRequest(collection, req.id),
                        ),
                        onTap: () => context.push('/request', extra: req),
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
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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

  Color _methodColor(String method) {
    return {
      'GET': const Color(0xFF61AFFE),
      'POST': const Color(0xFF49CC90),
      'PUT': const Color(0xFFFCA130),
      'PATCH': const Color(0xFF50E3C2),
      'DELETE': const Color(0xFFF93E3E),
      'HEAD': const Color(0xFF9012FE),
      'OPTIONS': const Color(0xFF0D5AA7),
    }[method] ?? Colors.grey;
  }
}
