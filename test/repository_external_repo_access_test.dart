import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/repository.dart';

void main() {
  group('isPermissionDeniedPathAccessError', () {
    test('returns true for permission denied messages', () {
      expect(
        isPermissionDeniedPathAccessError(
          Exception(
            "PathAccessException: Cannot open file (OS Error: Permission denied, errno = 13)",
          ),
        ),
        isTrue,
      );
    });

    test('returns false for unrelated errors', () {
      expect(
        isPermissionDeniedPathAccessError(
          Exception('network timeout'),
        ),
        isFalse,
      );
    });
  });
}
