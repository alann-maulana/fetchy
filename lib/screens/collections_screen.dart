import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/storage_provider.dart';
import '../services/postman_service.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final _postmanService = PostmanService();

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import Postman Collection',
            onPressed: _showImportDialog,
          ),
        ],
      ),
      body: collections.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text('No collections yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Create a collection to organize your requests',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: collections.length,
              itemBuilder: (_, i) {
                final col = collections[i];
                final allRequests = ref.read(savedRequestsProvider);
                final reqCount =
                    col.requestIds.where((id) => allRequests.any((r) => r.id == id)).length;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.folder,
                          color: theme.colorScheme.primary, size: 20),
                    ),
                    title: Text(col.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      '$reqCount requests${col.description != null && col.description!.isNotEmpty ? ' — ${col.description}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'rename', child: Text('Rename')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (v) {
                        if (v == 'rename') _renameCollection(col);
                        if (v == 'delete') _deleteCollection(col);
                      },
                    ),
                    onTap: () => context.push('/collections/${col.id}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCollection,
        icon: const Icon(Icons.create_new_folder),
        label: const Text('New Collection'),
      ),
    );
  }

  void _createCollection() {
    final controller = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Collection name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(collectionsProvider.notifier).create(
                      controller.text.trim(),
                      description: descController.text.trim(),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _renameCollection(dynamic col) {
    final controller = TextEditingController(text: col.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Collection name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(collectionsProvider.notifier)
                    .update(col.id, name: controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _deleteCollection(dynamic col) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Delete "${col.name}"? Requests in this collection will not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(collectionsProvider.notifier).delete(col.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
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
              _importFromJson(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _importFromJson(String jsonText) {
    if (jsonText.trim().isEmpty) return;
    try {
      final data = jsonDecode(jsonText) as Map<String, dynamic>;
      final result = _postmanService.importCollection(data);
      final collNotifier = ref.read(collectionsProvider.notifier);
      collNotifier.create(result.collection.name,
          description: result.collection.description);
      final requestsNotifier = ref.read(savedRequestsProvider.notifier);
      for (final req in result.requests) {
        requestsNotifier.save(req);
      }
      // Find the newly created collection and add requests
      final cols = ref.read(collectionsProvider);
      final newCol = cols.firstWhere(
        (c) => c.name == result.collection.name,
        orElse: () => cols.first,
      );
      for (final req in result.requests) {
        collNotifier.addRequest(newCol.id, req.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported "${result.collection.name}" with ${result.requests.length} requests'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
