import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/startup/startup_trace.dart';

void main() {
  test('StartupTrace writes mark messages', () {
    final lines = <String>[];
    final trace = StartupTrace('boot', sink: lines.add);

    trace.mark('step1');

    expect(lines.length, 1);
    expect(lines.first, contains('[boot]'));
    expect(lines.first, contains('step1'));
  });

  test('StartupTrace finish returns non-negative elapsed ms', () {
    final trace = StartupTrace('boot', sink: (_) {});

    final elapsed = trace.finish('end');

    expect(elapsed, greaterThanOrEqualTo(0));
  });
}
