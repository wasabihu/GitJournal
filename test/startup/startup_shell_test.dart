import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/startup/startup_shell.dart';

void main() {
  testWidgets('AppStartupShell shows loading indicator and message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppStartupShell(message: 'Loading repository...'),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading repository...'), findsOneWidget);
  });
}
