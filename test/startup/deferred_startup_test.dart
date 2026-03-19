import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/startup/deferred_startup.dart';

void main() {
  test('runDeferredStartupTasks runs tasks in order', () async {
    final calls = <String>[];

    await runDeferredStartupTasks(
      initLog: () async {
        calls.add('log');
      },
      initAnalytics: () async {
        calls.add('analytics');
      },
      confirmPurchase: () {
        calls.add('purchase');
      },
      reportErrorFn: (_, __) async {},
    );

    expect(calls, ['log', 'analytics', 'purchase']);
  });

  test('runDeferredStartupTasks continues when initLog fails', () async {
    final calls = <String>[];
    var reported = 0;

    await runDeferredStartupTasks(
      initLog: () async {
        calls.add('log');
        throw StateError('log failed');
      },
      initAnalytics: () async {
        calls.add('analytics');
      },
      confirmPurchase: () {
        calls.add('purchase');
      },
      reportErrorFn: (_, __) async {
        reported += 1;
      },
    );

    expect(calls, ['log', 'analytics', 'purchase']);
    expect(reported, 1);
  });

  test('runDeferredStartupTasks reports analytics failure and continues', () async {
    final calls = <String>[];
    var reported = 0;

    await runDeferredStartupTasks(
      initLog: () async {
        calls.add('log');
      },
      initAnalytics: () async {
        calls.add('analytics');
        throw StateError('analytics failed');
      },
      confirmPurchase: () {
        calls.add('purchase');
      },
      reportErrorFn: (_, __) async {
        reported += 1;
      },
    );

    expect(calls, ['log', 'analytics', 'purchase']);
    expect(reported, 1);
  });
}
