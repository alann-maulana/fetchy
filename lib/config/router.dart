import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/collections_screen.dart';
import '../screens/collection_detail_screen.dart';
import '../screens/environments_screen.dart';
import '../screens/environment_detail_screen.dart';
import '../screens/request_screen.dart';
import '../screens/settings_screen.dart';

import '../widgets/background_blobs.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/collections',
          builder: (context, state) => const CollectionsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => CollectionDetailScreen(
                collectionId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/environments',
          builder: (context, state) => const EnvironmentsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => EnvironmentDetailScreen(
                environmentId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/request',
      builder: (context, state) => const RequestScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundBlobs(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Collections',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Environments',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/collections')) return 1;
    if (location.startsWith('/environments')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/collections');
        break;
      case 2:
        context.go('/environments');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
