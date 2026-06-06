import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/spacing.dart';
import '../providers/storage_provider.dart';
import '../services/postman_service.dart';
import '../widgets/empty_state.dart';

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
    final colors = theme.colorScheme;

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
          ? EmptyState(
              icon: Icons.folder_outlined,
              title: 'No collections yet',
              subtitle: 'Group your API requests into collections',
              action: FilledButton.icon(
                onPressed: _createCollection,
                icon: const Icon(Icons.create_new_folder, size: 18),
                label: const Text('New Collection'),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: Spacing.sm, bottom: 80),
              itemCount: collections.length,
              itemBuilder: (_, i) {
                final col = collections[i];
                final allRequests = ref.read(savedRequestsProvider);
                final reqCount =
                    col.requestIds.where((id) => allRequests.any((r) => r.id == id)).length;

                return Card(
                  margin: EdgeInsets.fromLTRB(Spacing.lg, Spacing.xs, Spacing.lg, Spacing.xs),
                  child: InkWell(
                    onTap: () => context.push('/collections/${col.id}'),
                    borderRadius: BorderRadius.circular(Spacing.cardRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(Spacing.md),
                            ),
                            child: Icon(
                              Icons.folder,
                              color: colors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(col.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: Spacing.xxs),
                                Text(
                                  reqCount == 1 ? '1 request' : '$reqCount requests',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'rename', child: ListTile(
                                leading: Icon(Icons.edit_outlined, size: 18),
                                title: Text('Rename'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              )),
                              const PopupMenuItem(value: 'delete', child: ListTile(
                                leading: Icon(Icons.delete_outline, size: 18),
                                title: Text('Delete'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              )),
                            ],
                            onSelected: (v) {
                              if (v == 'rename') _renameCollection(col);
                              if (v == 'delete') _deleteCollection(col);
                            },
                          ),
                        ],
                      ),
                    ),
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
                hintText: 'Collection name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
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
        title: const Text('Rename collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Collection name',
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
        content: Text('Delete "${col.name}"? Requests inside will not be deleted.'),
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
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
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
          content: Text(
              'Imported "${result.collection.name}" with ${result.requests.length} requests'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
