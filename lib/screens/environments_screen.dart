import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/spacing.dart';
import '../providers/storage_provider.dart';
import '../services/postman_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';

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
    final colors = theme.colorScheme;

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
          ? EmptyState(
              icon: Icons.layers_outlined,
              title: 'No environments yet',
              subtitle: 'Create environments to manage variables',
              action: FilledButton.icon(
                onPressed: _createEnvironment,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Environment'),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: Spacing.sm, bottom: 80),
              itemCount: environments.length,
              itemBuilder: (_, i) {
                final env = environments[i];
                return GlassCard(
                  margin: EdgeInsets.fromLTRB(
                      Spacing.lg, Spacing.xs, Spacing.lg, Spacing.xs),
                  onTap: () =>
                      context.push('/environments/${env.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: env.isActive
                              ? colors.primaryContainer.withValues(alpha: 0.6)
                              : colors.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(Spacing.md),
                        ),
                        child: Icon(
                          env.isActive
                              ? Icons.check_circle
                              : Icons.layers_outlined,
                          color: env.isActive
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    env.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (env.isActive) ...[
                                  const SizedBox(width: Spacing.sm),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Spacing.sm,
                                        vertical: Spacing.xxs),
                                    decoration: BoxDecoration(
                                      color: colors.primaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(
                                              Spacing.chipRadius),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: Spacing.xxs),
                            Text(
                              '${env.variables.length} variables',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (_) => [
                          if (!env.isActive)
                            const PopupMenuItem(
                                value: 'activate',
                                child: ListTile(
                                  leading: Icon(Icons.play_circle_outline,
                                      size: 18),
                                  title: Text('Activate'),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                )),
                          const PopupMenuItem(
                              value: 'export',
                              child: ListTile(
                                leading: Icon(Icons.file_upload_outlined,
                                    size: 18),
                                title: Text('Export'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              )),
                          const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline,
                                    size: 18),
                                title: Text('Delete'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              )),
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
                    ],
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
            hintText: 'Environment name',
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
      final env = _postmanService.importEnvironment(data);
      ref.read(environmentsProvider.notifier).create(env.name);
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
