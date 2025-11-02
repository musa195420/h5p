import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtualh5p/local_web_view.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  testWidgets('LocalH5PWebView displays a progress bar until load completes',
      (WidgetTester tester) async {
    const testUrl = 'http://127.0.0.1:8080/index.html';

    await tester.pumpWidget(
      const MaterialApp(
        home: LocalH5PWebView(url: testUrl),
      ),
    );

    // WebView + Progress bar
    expect(find.byType(InAppWebView), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsWidgets);
  });
}
