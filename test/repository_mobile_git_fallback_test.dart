import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/repository.dart';

void main() {
  group('shouldFallbackToInternalStorageForUnsupportedMobileGit', () {
    test('returns true for unsupported mobile git error on external storage',
        () {
      final shouldFallback =
          shouldFallbackToInternalStorageForUnsupportedMobileGit(
        storeInternally: false,
        error: Exception(
            'GitFetch failed with error code: function not implemented'),
      );

      expect(shouldFallback, isTrue);
    });

    test('returns false when repository is already internal', () {
      final shouldFallback =
          shouldFallbackToInternalStorageForUnsupportedMobileGit(
        storeInternally: true,
        error: Exception(
            'GitFetch failed with error code: function not implemented'),
      );

      expect(shouldFallback, isFalse);
    });

    test('returns false for unrelated errors', () {
      final shouldFallback =
          shouldFallbackToInternalStorageForUnsupportedMobileGit(
        storeInternally: false,
        error: Exception('network timeout'),
      );

      expect(shouldFallback, isFalse);
    });
  });

  group('shouldContinueWithLocalOnlySyncAfterFetchFailure', () {
    test('returns true for function-not-implemented errors', () {
      final shouldContinue = shouldContinueWithLocalOnlySyncAfterFetchFailure(
        Exception('GitFetch failed with error code: function not implemented'),
      );

      expect(shouldContinue, isTrue);
    });

    test('returns true for unsupported operation errors', () {
      final shouldContinue = shouldContinueWithLocalOnlySyncAfterFetchFailure(
        Exception(
            'Git fetch failed because unsupported operation on this device'),
      );

      expect(shouldContinue, isTrue);
    });

    test('returns false for unrelated errors', () {
      final shouldContinue = shouldContinueWithLocalOnlySyncAfterFetchFailure(
        Exception('network timeout'),
      );

      expect(shouldContinue, isFalse);
    });
  });

  group('isLikelyRemoteAuthError', () {
    test('returns true for invalid auth method errors', () {
      final authError = isLikelyRemoteAuthError(
          Exception('GitFetch failed: invalid auth method'));

      expect(authError, isTrue);
    });

    test('returns true for unauthorized errors', () {
      final authError = isLikelyRemoteAuthError(Exception('401 unauthorized'));

      expect(authError, isTrue);
    });

    test('returns false for unrelated errors', () {
      final authError = isLikelyRemoteAuthError(Exception('network timeout'));

      expect(authError, isFalse);
    });
  });
}
