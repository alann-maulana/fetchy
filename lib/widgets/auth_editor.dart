import 'package:flutter/material.dart';
import '../config/spacing.dart';
import '../providers/request_provider.dart';

class AuthEditor extends StatelessWidget {
  final RequestEditorState state;
  final RequestEditorNotifier notifier;

  const AuthEditor({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final types = ['none', 'basic', 'bearer', 'apikey'];
    final labels = {
      'none': 'No Auth',
      'basic': 'Basic Auth',
      'bearer': 'Bearer Token',
      'apikey': 'API Key',
    };
    final icons = {
      'none': Icons.close,
      'basic': Icons.lock_outline,
      'bearer': Icons.key,
      'apikey': Icons.vpn_key,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: types.map((t) {
            final selected = state.authType == t;
            return ChoiceChip(
              avatar: Icon(icons[t], size: 16),
              label: Text(labels[t]!, style: const TextStyle(fontSize: 12)),
              selected: selected,
              onSelected: (_) => notifier.setAuthType(t),
            );
          }).toList(),
        ),
        const SizedBox(height: Spacing.lg),
        if (state.authType == 'basic') ...[
          TextField(
            controller: TextEditingController(text: state.authUsername)
              ..selection =
                  TextSelection.collapsed(offset: state.authUsername.length),
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(),
            ),
            onChanged: notifier.setAuthUsername,
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: TextEditingController(text: state.authPassword)
              ..selection =
                  TextSelection.collapsed(offset: state.authPassword.length),
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, size: 20),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            onChanged: notifier.setAuthPassword,
          ),
        ] else if (state.authType == 'bearer') ...[
          TextField(
            controller: TextEditingController(text: state.authToken)
              ..selection =
                  TextSelection.collapsed(offset: state.authToken.length),
            decoration: const InputDecoration(
              labelText: 'Token',
              prefixIcon: Icon(Icons.key, size: 20),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: notifier.setAuthToken,
          ),
        ] else if (state.authType == 'apikey') ...[
          TextField(
            controller: TextEditingController(text: state.authKey)
              ..selection =
                  TextSelection.collapsed(offset: state.authKey.length),
            decoration: const InputDecoration(
              labelText: 'Key',
              prefixIcon: Icon(Icons.label_outline, size: 20),
              border: OutlineInputBorder(),
            ),
            onChanged: notifier.setAuthKey,
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: TextEditingController(text: state.authValue)
              ..selection =
                  TextSelection.collapsed(offset: state.authValue.length),
            decoration: const InputDecoration(
              labelText: 'Value',
              prefixIcon: Icon(Icons.code, size: 20),
              border: OutlineInputBorder(),
            ),
            onChanged: notifier.setAuthValue,
          ),
          const SizedBox(height: Spacing.md),
          DropdownButtonFormField<String>(
            initialValue: state.authAddTo,
            decoration: const InputDecoration(
              labelText: 'Add to',
              prefixIcon: Icon(Icons.place, size: 20),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'header', child: Text('Header')),
              DropdownMenuItem(
                  value: 'query', child: Text('Query Parameters')),
            ],
            onChanged: (v) {
              if (v != null) notifier.setAuthAddTo(v);
            },
          ),
        ],
      ],
    );
  }
}
