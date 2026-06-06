import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/spacing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          const SizedBox(height: Spacing.sm),

          // Appearance section
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode, size: 18),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (v) {
                      ref.read(themeModeProvider.notifier).state = v.first;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // About section
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.sm),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(Spacing.md),
                    ),
                    child: Icon(Icons.http, color: colors.primary, size: 20),
                  ),
                  title: const Text(
                    'Fetchy',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text('Mobile REST API Client'),
                ),
                Divider(height: 1, indent: Spacing.lg + 52),
                const ListTile(
                  title: Text('Version', style: TextStyle(fontSize: 14)),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
