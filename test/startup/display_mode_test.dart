import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/startup/display_mode.dart';

void main() {
  test('setHighRefreshRateSafely skips when not mobile', () async {
    var called = false;

    await setHighRefreshRateSafely(
      isMobile: false,
      setHighRefreshRate: () async {
        called = true;
      },
      reportErrorFn: (_, __) async {},
    );

    expect(called, isFalse);
  });

  test('setHighRefreshRateSafely reports errors', () async {
    Object? reportedError;

    await setHighRefreshRateSafely(
      isMobile: true,
      setHighRefreshRate: () async {
        throw StateError('display mode failed');
      },
      reportErrorFn: (error, _) async {
        reportedError = error;
      },
    );

    expect(reportedError, isA<Exception>());
  });

  test('setHighRefreshRateSafely reports timeout', () async {
    Object? reportedError;
    final completer = Completer<void>();

    await setHighRefreshRateSafely(
      isMobile: true,
      timeout: const Duration(milliseconds: 10),
      setHighRefreshRate: () => completer.future,
      reportErrorFn: (error, _) async {
        reportedError = error;
      },
    );

    expect(reportedError, isA<Exception>());
    expect(completer.isCompleted, isFalse);
  });
}
