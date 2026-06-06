import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/environment.dart';
import '../providers/storage_provider.dart';

class EnvironmentDetailScreen extends ConsumerStatefulWidget {
  final String environmentId;

  const EnvironmentDetailScreen({super.key, required this.environmentId});

  @override
  ConsumerState<EnvironmentDetailScreen> createState() =>
      _EnvironmentDetailScreenState();
}

class _EnvironmentDetailScreenState
    extends ConsumerState<EnvironmentDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _keyController = TextEditingController();
    _valueController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final envs = ref.watch(environmentsProvider);
    final env = envs.where((e) => e.id == widget.environmentId).firstOrNull;
    final theme = Theme.of(context);

    if (env == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Environment')),
        body: const Center(child: Text('Environment not found')),
      );
    }

    if (!_isEditing) {
      _nameController.text = env.name;
    }

    final variables = Map<String, String>.from(env.variables);
    final variableList = variables.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(border: InputBorder.none),
              )
            : Text(env.name),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveName,
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
              onSelected: (v) => _handleAction(v, env),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildHeader(env, theme),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Variables',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${variableList.length} entries',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            child: variableList.isEmpty
                ? Center(
                    child: Text('No variables yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  )
                : ListView.builder(
                    itemCount: variableList.length,
                    itemBuilder: (_, i) {
                      final entry = variableList[i];
                      return _VariableRow(
                        key: ValueKey(entry.key),
                        keyName: entry.key,
                        value: entry.value,
                        onKeyChanged: (v) => _updateVariable(
                            env, entry.key, v, entry.value),
                        onValueChanged: (v) => _updateVariable(
                            env, entry.key, entry.key, v),
                        onDelete: () => _deleteVariable(env, entry.key),
                      );
                    },
                  ),
          ),
          _buildAddSection(env, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(Environment env, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: env.isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Icon(
            env.isActive ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: env.isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                env.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: env.isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${env.variables.length} variables',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const Spacer(),
          if (!env.isActive)
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(environmentsProvider.notifier).activate(env.id),
              child: const Text('Activate'),
            ),
        ],
      ),
    );
  }

  Widget _buildAddSection(Environment env, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    hintText: 'Variable name',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    hintText: 'Value',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                onPressed: () => _addVariable(env),
                style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addVariable(Environment env) {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();
    if (key.isEmpty) return;

    final updated = Map<String, String>.from(env.variables);
    updated[key] = value;
    ref.read(environmentsProvider.notifier).update(env.id, variables: updated);

    _keyController.clear();
    _valueController.clear();
  }

  void _updateVariable(
      Environment env, String oldKey, String newKey, String value) {
    final updated = Map<String, String>.from(env.variables);
    updated.remove(oldKey);
    if (newKey.isNotEmpty) {
      updated[newKey] = value;
    }
    ref.read(environmentsProvider.notifier).update(env.id, variables: updated);
  }

  void _deleteVariable(Environment env, String key) {
    final updated = Map<String, String>.from(env.variables);
    updated.remove(key);
    ref.read(environmentsProvider.notifier).update(env.id, variables: updated);
  }

  void _saveName() {
    ref
        .read(environmentsProvider.notifier)
        .update(widget.environmentId, name: _nameController.text);
    setState(() => _isEditing = false);
  }

  void _handleAction(String action, Environment env) {
    switch (action) {
      case 'delete':
        _deleteEnvironment(env);
    }
  }

  void _deleteEnvironment(Environment env) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Environment'),
        content: Text('Delete "${env.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(environmentsProvider.notifier).delete(env.id);
              Navigator.pop(ctx);
              context.pop();
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _VariableRow extends StatelessWidget {
  final String keyName;
  final String value;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<String> onValueChanged;
  final VoidCallback onDelete;

  const _VariableRow({
    super.key,
    required this.keyName,
    required this.value,
    required this.onKeyChanged,
    required this.onValueChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: keyName)
                ..selection =
                    TextSelection.collapsed(offset: keyName.length),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              onChanged: onKeyChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              onChanged: onValueChanged,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
