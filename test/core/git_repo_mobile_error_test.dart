/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:dart_git/config.dart';
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
        usesSshRemote: true,
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
        usesSshRemote: false,
      );

      expect(identical(mapped, ex), isTrue);
    });

    test('uses generic unsupported message for https remotes', () {
      final ex = mapMobileGitException(
        operation: 'Git fetch',
        error: Exception(
          'GitFetch failed with error code: function not implemented',
        ),
        usesEd25519Key: true,
        usesSshRemote: false,
      );

      expect(ex.toString(), contains('unsupported operation on this device'));
      expect(ex.toString(), isNot(contains('Ed25519 SSH keys')));
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

  group('isFunctionNotImplementedGitError', () {
    test('returns true for function not implemented errors', () {
      expect(
        isFunctionNotImplementedGitError(
          Exception('GitPush failed with error code: function not implemented'),
        ),
        isTrue,
      );
    });

    test('returns false for unrelated errors', () {
      expect(
        isFunctionNotImplementedGitError(Exception('network timeout')),
        isFalse,
      );
    });
  });

  group('isUnsupportedMobileGitEngineError', () {
    test('returns true for unsupported operation message', () {
      expect(
        isUnsupportedMobileGitEngineError(
          Exception(
              'Git fetch failed because unsupported operation on this device'),
        ),
        isTrue,
      );
    });

    test('returns true for mapped ed25519 unsupported message', () {
      expect(
        isUnsupportedMobileGitEngineError(
          Exception(
            'Git fetch failed because the current mobile Git engine does not support Ed25519 SSH keys on some devices.',
          ),
        ),
        isTrue,
      );
    });

    test('returns false for unrelated errors', () {
      expect(
        isUnsupportedMobileGitEngineError(Exception('network timeout')),
        isFalse,
      );
    });
  });

  group('tryConvertSshRemoteToHttps', () {
    test('converts git@host:path format', () {
      expect(
        tryConvertSshRemoteToHttps('git@github.com:wasabihu/note.git'),
        'https://github.com/wasabihu/note.git',
      );
    });

    test('converts git@host/path format', () {
      expect(
        tryConvertSshRemoteToHttps('git@github.com/wasabihu/note.git'),
        'https://github.com/wasabihu/note.git',
      );
    });

    test('converts ssh://git@host/path format', () {
      expect(
        tryConvertSshRemoteToHttps('ssh://git@github.com/wasabihu/note.git'),
        'https://github.com/wasabihu/note.git',
      );
    });

    test('converts ssh://host:port/path format', () {
      expect(
        tryConvertSshRemoteToHttps('ssh://git@github.com:22/wasabihu/note.git'),
        'https://github.com/wasabihu/note.git',
      );
    });

    test('returns null for non-ssh url', () {
      expect(
        tryConvertSshRemoteToHttps('https://github.com/wasabihu/note.git'),
        isNull,
      );
    });
  });

  group('isLikelySshRemoteUrl', () {
    test('returns true for ssh remote formats', () {
      expect(isLikelySshRemoteUrl('git@github.com:wasabihu/note.git'), isTrue);
      expect(
        isLikelySshRemoteUrl('ssh://git@github.com/wasabihu/note.git'),
        isTrue,
      );
    });

    test('returns false for https remotes', () {
      expect(
        isLikelySshRemoteUrl('https://github.com/wasabihu/note.git'),
        isFalse,
      );
    });
  });

  group('findConvertibleRemoteForHttps', () {
    test('prefers origin when origin is convertible', () {
      final remotes = <GitRemoteConfig?>[
        GitRemoteConfig.create(
          name: 'upstream',
          url: 'git@gitlab.com:team/repo.git',
        ),
        GitRemoteConfig.create(
          name: 'origin',
          url: 'git@github.com:wasabihu/note.git',
        ),
      ];

      final result = findConvertibleRemoteForHttps(remotes);
      expect(result.$1, 1);
      expect(result.$2, 'https://github.com/wasabihu/note.git');
    });

    test('falls back when origin is already https', () {
      final remotes = <GitRemoteConfig?>[
        GitRemoteConfig.create(
          name: 'origin',
          url: 'https://github.com/wasabihu/note.git',
        ),
        GitRemoteConfig.create(
          name: 'backup',
          url: 'git@gitlab.com:team/repo.git',
        ),
      ];

      final result = findConvertibleRemoteForHttps(remotes);
      expect(result.$1, 1);
      expect(result.$2, 'https://gitlab.com/team/repo.git');
    });

    test('returns null when no remote can be converted', () {
      final remotes = <GitRemoteConfig?>[
        GitRemoteConfig.create(
          name: 'origin',
          url: 'https://github.com/wasabihu/note.git',
        ),
      ];

      final result = findConvertibleRemoteForHttps(remotes);
      expect(result.$1, isNull);
      expect(result.$2, isNull);
    });
  });
}
