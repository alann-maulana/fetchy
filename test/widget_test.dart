import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fetchy/models/api_request.dart';
import 'package:fetchy/models/collection.dart';
import 'package:fetchy/models/environment.dart';
import 'package:fetchy/main.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final path = '.test_hive';
    Hive.init(path);
    Hive.registerAdapter(ApiRequestAdapter());
    Hive.registerAdapter(CollectionAdapter());
    Hive.registerAdapter(EnvironmentAdapter());
    await Hive.openBox<ApiRequest>('requests');
    await Hive.openBox<Collection>('collections');
    await Hive.openBox<Environment>('environments');
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('requests');
    await Hive.deleteBoxFromDisk('collections');
    await Hive.deleteBoxFromDisk('environments');
  });

  testWidgets('App launches with home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FetchyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('No saved requests yet'), findsOneWidget);
    expect(find.text('Create your first API request to get started'), findsOneWidget);
    expect(find.text('New Request'), findsWidgets);
  });
}
