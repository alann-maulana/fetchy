import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/api_request.dart';
import 'models/collection.dart';
import 'models/environment.dart';
import 'config/theme.dart';
import 'config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ApiRequestAdapter());
  Hive.registerAdapter(CollectionAdapter());
  Hive.registerAdapter(EnvironmentAdapter());

  await Hive.openBox<ApiRequest>('requests');
  await Hive.openBox<Collection>('collections');
  await Hive.openBox<Environment>('environments');

  runApp(
    const ProviderScope(
      child: FetchyApp(),
    ),
  );
}

class FetchyApp extends ConsumerWidget {
  const FetchyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Fetchy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
