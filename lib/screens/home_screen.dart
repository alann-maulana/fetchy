import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';
import '../config/theme.dart';
import '../config/spacing.dart';
import '../config/typography.dart';
import '../models/api_request.dart';
import '../providers/storage_provider.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(savedRequestsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        actions: [
          if (requests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Spacing.chipRadius),
                ),
                child: Text(
                  '${requests.length}',
                  style: AppTextStyles.labelCaps.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
      body: requests.isEmpty
              ? EmptyState(
                  icon: Icons.http,
                  title: 'No saved requests yet',
                  subtitle: 'Create your first API request to get started',
                  action: FilledButton.icon(
                    onPressed: () => context.push('/request'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Request'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(savedRequestsProvider),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: Spacing.sm, bottom: 80),
                    itemCount: requests.length,
                    itemBuilder: (_, i) {
                      final req = requests[i];
                      return _RequestCard(
                        request: req,
                        index: i,
                        onTap: () => context.push('/request', extra: req),
                        onDelete: () => _deleteRequest(ref, req),
                        onRename: () => _renameRequest(context, ref, req),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/request'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  void _deleteRequest(WidgetRef ref, ApiRequest req) {
    ref.read(savedRequestsProvider.notifier).delete(req.id);
  }

  void _renameRequest(BuildContext context, WidgetRef ref, ApiRequest req) {
    final controller = TextEditingController(text: req.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename request'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Request name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(savedRequestsProvider.notifier)
                    .rename(req.id, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ApiRequest request;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _RequestCard({
    required this.request,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final method = request.method.toUpperCase();
    final mColor = method.methodColor;

    return GlassCard(
      margin: EdgeInsets.fromLTRB(Spacing.lg, Spacing.xs, Spacing.lg, Spacing.xs),
      onTap: onTap,
      child: Row(
        children: [
          // Method badge
          Container(
            constraints: BoxConstraints(minWidth: 48),
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: mColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Spacing.chipRadius),
              border: Border.all(color: mColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              method,
              style: AppTextStyles.methodBadge.copyWith(color: mColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  request.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.codeSmall.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
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
              if (v == 'rename') onRename();
              if (v == 'delete') onDelete();
            },
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 350.ms,
      delay: (50 * index).ms,
    ).slideX(begin: 0.04, end: 0);
  }
}
