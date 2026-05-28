import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('shows the welcome landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const PackPalApp());

    expect(find.text('PackPal'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
