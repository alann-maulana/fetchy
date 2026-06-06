import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/storage_provider.dart';
import '../services/postman_service.dart';

class EnvironmentsScreen extends ConsumerStatefulWidget {
  const EnvironmentsScreen({super.key});

  @override
  ConsumerState<EnvironmentsScreen> createState() =>
      _EnvironmentsScreenState();
}

class _EnvironmentsScreenState extends ConsumerState<EnvironmentsScreen> {
  final _postmanService = PostmanService();

  @override
  Widget build(BuildContext context) {
    final environments = ref.watch(environmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Environments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import Postman Environment',
            onPressed: _showImportDialog,
          ),
        ],
      ),
      body: environments.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.layers_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text('No environments yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Create environments to manage variables',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: environments.length,
              itemBuilder: (_, i) {
                final env = environments[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: env.isActive
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        env.isActive ? Icons.check_circle : Icons.layers_outlined,
                        color: env.isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(env.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (env.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                )),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${env.variables.length} variables',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        if (!env.isActive)
                          const PopupMenuItem(
                              value: 'activate', child: Text('Activate')),
                        const PopupMenuItem(
                            value: 'export', child: Text('Export to clipboard')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (v) {
                        if (v == 'activate') {
                          ref
                              .read(environmentsProvider.notifier)
                              .activate(env.id);
                        } else if (v == 'export') {
                          _exportEnvironment(env);
                        } else if (v == 'delete') {
                          _deleteEnvironment(env);
                        }
                      },
                    ),
                    onTap: () =>
                        context.push('/environments/${env.id}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createEnvironment,
        icon: const Icon(Icons.add),
        label: const Text('New Environment'),
      ),
    );
  }

  void _createEnvironment() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Environment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Environment name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(environmentsProvider.notifier)
                    .create(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _exportEnvironment(dynamic env) {
    final json = _postmanService.exportEnvironment(env);
    final pretty = const JsonEncoder.withIndent('  ').convert(json);
    Clipboard.setData(ClipboardData(text: pretty));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Environment exported to clipboard')),
    );
  }

  void _deleteEnvironment(dynamic env) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Environment'),
        content: Text('Delete "${env.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(environmentsProvider.notifier).delete(env.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
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
        title: const Text('Import Postman Environment'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste Postman Environment JSON here...',
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
      final env = _postmanService.importEnvironment(data);
      ref.read(environmentsProvider.notifier).create(env.name);
      // Update with imported variables
      final envs = ref.read(environmentsProvider);
      final newEnv = envs.firstWhere(
        (e) => e.name == env.name,
        orElse: () => envs.first,
      );
      ref
          .read(environmentsProvider.notifier)
          .update(newEnv.id, variables: env.variables);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Imported "${env.name}" with ${env.variables.length} variables'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
