// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:life_mathematics/main.dart';
import 'package:life_mathematics/providers/history_provider.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ],
        child: const LifeMathematicsApp(isDarkMode: false),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the app title is shown
    expect(find.text('Life Mathematics'), findsOneWidget);

    // Verify bottom navigation is present
    expect(find.byIcon(Icons.calculate), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });
}
