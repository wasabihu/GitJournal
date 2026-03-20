import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/repository.dart';
import 'package:universal_io/io.dart' as io;

void main() {
  group('canIgnoreSourceRepoDeleteErrorForMove', () {
    test('returns true for directory not empty errors', () {
      const error = io.FileSystemException(
        'Deletion failed (Directory not empty, errno = 39)',
        '/storage/emulated/0/Documents/note4/note/',
      );

      expect(canIgnoreSourceRepoDeleteErrorForMove(error), isTrue);
    });

    test('returns false for unrelated filesystem errors', () {
      const error = io.FileSystemException(
        'Deletion failed (Permission denied, errno = 13)',
        '/tmp/repo',
      );

      expect(canIgnoreSourceRepoDeleteErrorForMove(error), isFalse);
    });
  });
}
