import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_h5p/example/test_view.dart';

void main() {
  testWidgets('renders app bar and button list', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocalWebView()));

    // Check for title
    expect(find.text("H5P Local Viewer"), findsOneWidget);

    // Since no URLs initially loaded, should show placeholder text
    expect(find.text("Select an H5P file to load"), findsOneWidget);
  });

  testWidgets('status indicator updates based on status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocalWebView()));

    // Find the AnimatedContainer
    expect(find.byType(AnimatedContainer), findsOneWidget);

    // You can simulate status changes
    // In real-world widget tests, you would use H5PLoader mock or
    // Provider pattern to simulate this — for now, just smoke test UI.
  });
}
