import 'package:flutter_test/flutter_test.dart';

import 'package:life_mathematics/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeMathematicsApp(isDarkMode: false));
    expect(find.text('Calculator'), findsOneWidget);
  });
}
