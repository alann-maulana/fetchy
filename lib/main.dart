import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters (will be generated)
  // Hive.registerAdapter(ApiRequestAdapter());
  // Hive.registerAdapter(CollectionAdapter());
  // Hive.registerAdapter(EnvironmentAdapter());
  
  // Open boxes
  // await Hive.openBox<ApiRequest>('requests');
  // await Hive.openBox<Collection>('collections');
  // await Hive.openBox<Environment>('environments');
  
  runApp(
    const ProviderScope(
      child: FetchyApp(),
    ),
  );
}

class FetchyApp extends StatelessWidget {
  const FetchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fetchy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
