import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fetchy/main.dart';

void main() {
  testWidgets('App launches with home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FetchyApp()));

    // Verify that the app launches
    expect(find.text('Home Screen - Request List'), findsOneWidget);
  });
}
