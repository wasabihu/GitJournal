import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/repository.dart';

void main() {
  test('skip commit when repository is internal', () async {
    var called = false;

    await maybeCommitExternalChangesOnLoad(
      storeInternally: true,
      commitFn: () async {
        called = true;
      },
    );

    expect(called, isFalse);
  });

  test('commit when repository is external', () async {
    var called = false;

    await maybeCommitExternalChangesOnLoad(
      storeInternally: false,
      commitFn: () async {
        called = true;
      },
    );

    expect(called, isTrue);
  });

  test('timeout does not throw for external repository', () async {
    final completer = Completer<void>();

    await maybeCommitExternalChangesOnLoad(
      storeInternally: false,
      timeout: const Duration(milliseconds: 20),
      commitFn: () => completer.future,
    );

    expect(completer.isCompleted, isFalse);
  });

  test('sync timeout does not throw for external repository', () async {
    final completer = Completer<void>();

    await maybeCommitExternalChangesBeforeSync(
      storeInternally: false,
      timeout: const Duration(milliseconds: 20),
      commitFn: () => completer.future,
    );

    expect(completer.isCompleted, isFalse);
  });
}
