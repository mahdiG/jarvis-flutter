import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarvis_flutter/main.dart';

void main() {
  testWidgets('Chat screen shows welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const JarvisApp());

    // Verify that the welcome message is displayed
    expect(find.text("Hello! I'm Jarvis AI. How can I help you today?"), findsOneWidget);
    expect(find.text('AI Chat'), findsOneWidget);
  });

  testWidgets('User can type and send a message', (WidgetTester tester) async {
    await tester.pumpWidget(const JarvisApp());

    // Find the text field and type a message
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Hello');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    // Verify the user message appears
    expect(find.text('Hello'), findsOneWidget);

    // Pump the delayed AI response timer
    await tester.pump(const Duration(seconds: 1));

    // Verify the AI response appears
    expect(find.text('I received your message: "Hello"'), findsOneWidget);
  });
}