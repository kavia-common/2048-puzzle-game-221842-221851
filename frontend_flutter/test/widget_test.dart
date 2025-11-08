import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/main.dart';

void main() {
  testWidgets('App builds with title 2048 and theme', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('2048'), findsOneWidget);
  });
}
