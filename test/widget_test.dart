import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_mathematics/main.dart';

void main() {
  testWidgets('App renders with navigation structure', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeMathematicsApp(isDarkMode: false));
    await tester.pump();

    expect(find.text('Life Mathematics'), findsOneWidget);
    expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
  });
}
