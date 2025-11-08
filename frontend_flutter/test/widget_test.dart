import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/main.dart';

void main() {
  testWidgets('App boots with Provider and shows expected UI elements', (tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Let initial async microtasks settle (e.g., provider notifications)
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1) AppBar title "2048"
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('2048'), findsWidgets); // title text appears in appbar and possibly MaterialApp title

    // 2) Score labels and values
    // Labels: "SCORE" and "BEST" are uppercased in the ScoreBar
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);

    // Initial values should be present (0 for both at start)
    expect(find.text('0'), findsWidgets);

    // 3) Board grid placeholders: ensure 16 background cells exist
    // The background placeholders are rendered as Containers in a grid inside a Card.
    // We assert by counting the grid cells via a Finder on Containers that are descendants of Card.
    final cardFinder = find.byType(Card);
    expect(cardFinder, findsOneWidget);

    // Within the Card, there should be 16 placeholder cells rendered in the background grid.
    // We approximate by counting descendant Containers with a border decoration (used for placeholders).
    int placeholderCount = 0;
    cardFinder.evaluate().forEach((element) {
      element.visitChildren((child) {
        // Traverse subtree
        void visit(Element e) {
          final widget = e.widget;
          if (widget is Container) {
            final decoration = widget.decoration;
            if (decoration is BoxDecoration && decoration.border != null) {
              // Count only Containers that look like grid placeholders (have a border)
              placeholderCount++;
            }
          }
          e.visitChildren(visit);
        }

        visit(child);
      });
    });

    // Assert we have at least 16 placeholders (exact 16 targeted grid cells)
    // Some tiles or nested containers may add more bordered containers, so use >= 16
    expect(placeholderCount >= 16, isTrue, reason: 'Expected at least 16 grid placeholders');

    // 4) Controls: Undo and Restart buttons
    expect(find.widgetWithText(OutlinedButton, 'Undo'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Restart'), findsOneWidget);

    // 5) Ensure no exceptions occurred due to provider initialization
    // Flutter test will fail on uncaught exceptions; we can also do a no-op tap to ensure tree is stable.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Restart'));
    await tester.pumpAndSettle();
  });
}
