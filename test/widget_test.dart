import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_mathematics/main.dart';

void main() {
  testWidgets('App renders with navigation structure',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LifeMathematicsApp(isDarkMode: false));
    await tester.pump();

    expect(find.text('Life Mathematics'), findsOneWidget);
    // Every tab stays mounted inside the IndexedStack, so match on the nav
    // labels rather than icons (History's empty state reuses the same icon).
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Smart Calc'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
  });

  testWidgets('the calculation survives leaving and returning to the tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LifeMathematicsApp(isDarkMode: true));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('7'));
    await tester.tap(find.bySemanticsLabel('Add'));
    await tester.tap(find.bySemanticsLabel('8'));
    await tester.tap(find.bySemanticsLabel('Equals'));
    await tester.pump();

    expect(find.text('15'), findsOneWidget);

    // Leave for Smart Calc and come back.
    await tester.tap(find.text('Smart Calc'));
    await tester.pump();
    await tester.tap(find.text('Calculator'));
    await tester.pump();

    // Previously the state was rebuilt from scratch and this showed '0'.
    expect(find.text('15'), findsOneWidget);
    expect(find.text('7 + 8 ='), findsOneWidget);
  });
}
