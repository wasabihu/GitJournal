import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_setup/error.dart';
import 'package:gitjournal/l10n.dart';

void main() {
  testWidgets('GitHostSetupErrorPage is scrollable for long errors', (
    WidgetTester tester,
  ) async {
    final message = List.filled(80, 'very long clone error line').join('\n');

    await tester.binding.setSurfaceSize(const Size(320, 480));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: gitJournalLocalizationDelegates,
        supportedLocales: gitJournalSupportedLocales,
        home: Scaffold(
          body: GitHostSetupErrorPage(message),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
