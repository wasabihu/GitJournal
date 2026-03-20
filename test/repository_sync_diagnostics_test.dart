import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/repository.dart';

void main() {
  group('sanitizeRemoteUrlForDisplay', () {
    test('masks credentials in https remotes', () {
      final masked = sanitizeRemoteUrlForDisplay(
        'https://x-access-token:abc123@github.com/wasabihu/note.git',
      );

      expect(masked, 'https://***@github.com/wasabihu/note.git');
    });

    test('keeps ssh remotes unchanged', () {
      final val = sanitizeRemoteUrlForDisplay(
        'git@github.com:wasabihu/note.git',
      );

      expect(val, 'git@github.com:wasabihu/note.git');
    });
  });
}
