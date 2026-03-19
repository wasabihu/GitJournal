import 'package:flutter_test/flutter_test.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:gitjournal/repository.dart';

void main() {
  test('computeInitialFileStorageCacheReady returns true in fast startup mode', () {
    final ready = computeInitialFileStorageCacheReady(
      fastStartupMode: true,
      headHash: GitHash.zero(),
      lastProcessedHead: GitHash('1234567890123456789012345678901234567890'),
    );

    expect(ready, isTrue);
  });

  test('computeInitialFileStorageCacheReady compares hashes in normal mode', () {
    final hash = GitHash('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

    expect(
      computeInitialFileStorageCacheReady(
        fastStartupMode: false,
        headHash: hash,
        lastProcessedHead: hash,
      ),
      isTrue,
    );

    expect(
      computeInitialFileStorageCacheReady(
        fastStartupMode: false,
        headHash: GitHash.zero(),
        lastProcessedHead: hash,
      ),
      isFalse,
    );
  });
}
