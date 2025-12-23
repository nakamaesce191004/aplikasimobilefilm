import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_film/webview_player_page.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('WebViewPlayerPage compiles and builds', (WidgetTester tester) async {
    // webview_flutter usually requires platform channel mocking in tests, 
    // but we just want to ensure it compiles and widget tree is valid.
    // We'll wrap it in a try-catch or expect it to throw a MissingPluginException which confirms code is reached.
    
    await tester.pumpWidget(const MaterialApp(
      home: WebViewPlayerPage(url: 'https://google.com', title: 'Test Browser'),
    ));
    
    expect(find.text('Test Browser'), findsOneWidget);
  });
}
