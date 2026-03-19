import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/folder_views/folder_view_configuration_dialog.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/l10n.dart';

void main() {
  testWidgets('dialog updates selection immediately and triggers callbacks', (
    WidgetTester tester,
  ) async {
    StandardViewHeader? changedHeader;
    bool? changedSummary;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: gitJournalLocalizationDelegates,
        supportedLocales: gitJournalSupportedLocales,
        home: Scaffold(
          body: FolderViewConfigurationDialog(
            headerType: StandardViewHeader.TitleOrFileName,
            showSummary: true,
            onHeaderTypeChanged: (header) => changedHeader = header,
            onShowSummaryChanged: (showSummary) =>
                changedSummary = showSummary,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fileNameOnlyFinder = find.byKey(const ValueKey("ShowFileNameOnly"));
    expect(fileNameOnlyFinder, findsOneWidget);

    await tester.tap(fileNameOnlyFinder);
    await tester.pumpAndSettle();

    expect(changedHeader, StandardViewHeader.FileName);

    final summaryToggleFinder = find.byKey(const ValueKey("SummaryToggle"));
    expect(summaryToggleFinder, findsOneWidget);
    expect(tester.widget<SwitchListTile>(summaryToggleFinder).value, isTrue);

    await tester.tap(summaryToggleFinder);
    await tester.pumpAndSettle();

    expect(changedSummary, isFalse);
    expect(tester.widget<SwitchListTile>(summaryToggleFinder).value, isFalse);
  });
}
