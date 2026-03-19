import 'package:gitjournal/setup/clone.dart';
import 'package:test/test.dart';

void main() {
  test('tryCloneWithRetries retries and succeeds on second attempt', () async {
    var cloneCalls = 0;
    var cleanupCalls = 0;

    final success = await tryCloneWithRetries(
      cloneOnce: () async {
        cloneCalls += 1;
        if (cloneCalls == 1) {
          throw Exception(
            'GitClone failed with error: rename /tmp/.git/objects/pack/tmp_pack_1 /tmp/.git/objects/pack/pack-1.pack',
          );
        }
      },
      cleanupRepoDir: () async {
        cleanupCalls += 1;
      },
      retryDelay: Duration.zero,
    );

    expect(success, isTrue);
    expect(cloneCalls, 2);
    expect(cleanupCalls, 1);
  });

  test('tryCloneWithRetries does not retry non-retryable errors', () async {
    var cloneCalls = 0;
    var cleanupCalls = 0;

    await expectLater(
      () => tryCloneWithRetries(
        cloneOnce: () async {
          cloneCalls += 1;
          throw Exception('network down');
        },
        cleanupRepoDir: () async {
          cleanupCalls += 1;
        },
        retryDelay: Duration.zero,
      ),
      throwsA(isA<Exception>()),
    );

    expect(cloneCalls, 1);
    expect(cleanupCalls, 0);
  });

  test('tryCloneWithRetries returns false when retryable failure persists',
      () async {
    var cloneCalls = 0;
    var cleanupCalls = 0;

    final success = await tryCloneWithRetries(
      cloneOnce: () async {
        cloneCalls += 1;
        throw Exception(
          'GitClone failed with error: rename /tmp/.git/objects/pack/tmp_pack_1 /tmp/.git/objects/pack/pack-1.pack',
        );
      },
      cleanupRepoDir: () async {
        cleanupCalls += 1;
      },
      retryDelay: Duration.zero,
      maxAttempts: 2,
    );

    expect(success, isFalse);
    expect(cloneCalls, 2);
    expect(cleanupCalls, 1);
  });
}
