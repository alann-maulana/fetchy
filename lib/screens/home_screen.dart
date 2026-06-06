import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/api_request.dart';
import '../providers/storage_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(savedRequestsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.api_outlined,
                      size: 64, color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text('No saved requests yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first request',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: requests.length,
              itemBuilder: (_, i) {
                final req = requests[i];
                final methodColor = _methodColor(req.method);
                return _RequestTile(
                  request: req,
                  methodColor: methodColor,
                  onTap: () => context.push('/request', extra: req),
                  onDelete: () => _deleteRequest(ref, req),
                  onRename: () => _renameRequest(context, ref, req),
                );
              },
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
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Request name',
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

class _RequestTile extends StatelessWidget {
  final ApiRequest request;
  final Color methodColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _RequestTile({
    required this.request,
    required this.methodColor,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: methodColor.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: methodColor.withAlpha(80)),
        ),
        child: Text(
          request.method,
          style: TextStyle(
            color: methodColor,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
      title: Text(request.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        request.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall
            ?.copyWith(fontFamily: 'monospace', color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: PopupMenuButton<String>(
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'rename', child: Text('Rename')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
        onSelected: (v) {
          if (v == 'rename') onRename();
          if (v == 'delete') onDelete();
        },
      ),
      onTap: onTap,
    );
  }
}
