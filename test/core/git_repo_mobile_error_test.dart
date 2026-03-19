/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('mapMobileGitException', () {
    test('maps function not implemented for Ed25519 keys to actionable error',
        () {
      final ex = mapMobileGitException(
        operation: 'Git fetch',
        error: Exception(
            'GitFetch failed with error code: function not implemented'),
        usesEd25519Key: true,
      );

      expect(
        ex.toString(),
        contains('does not support Ed25519 SSH keys'),
      );
      expect(
        ex.toString(),
        contains('RSA SSH key'),
      );
    });

    test('preserves original exception when not an Ed25519 compatibility issue',
        () {
      final ex = Exception('network timeout');
      final mapped = mapMobileGitException(
        operation: 'Git fetch',
        error: ex,
        usesEd25519Key: false,
      );

      expect(identical(mapped, ex), isTrue);
    });
  });

  group('usesEd25519Key', () {
    test('detects Ed25519 from saved public key', () {
      SharedPreferences.setMockInitialValues({});
      final pref = SharedPreferences.getInstance();

      return pref.then((p) {
        final config = GitConfig('test', p)
          ..sshPublicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI test@example';

        expect(usesEd25519Key(config), isTrue);
      });
    });
  });
}
