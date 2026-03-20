/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/config.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('pickConvertibleRemote', () {
    test('prefers origin when it can be converted', () {
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

      final result = pickConvertibleRemote(remotes);
      expect(result.$1, 1);
      expect(result.$2, 'https://github.com/wasabihu/note.git');
    });

    test('falls back to another remote when origin is already https', () {
      final remotes = <GitRemoteConfig?>[
        GitRemoteConfig.create(
          name: 'origin',
          url: 'https://github.com/wasabihu/note.git',
        ),
        GitRemoteConfig.create(
          name: 'upstream',
          url: 'git@gitlab.com:team/repo.git',
        ),
      ];

      final result = pickConvertibleRemote(remotes);
      expect(result.$1, 1);
      expect(result.$2, 'https://gitlab.com/team/repo.git');
    });

    test('returns nulls when no remote can be converted', () {
      final remotes = <GitRemoteConfig?>[
        GitRemoteConfig.create(
          name: 'origin',
          url: 'https://github.com/wasabihu/note.git',
        ),
        GitRemoteConfig.create(
          name: 'backup',
          url: 'https://gitlab.com/team/repo.git',
        ),
      ];

      final result = pickConvertibleRemote(remotes);
      expect(result.$1, isNull);
      expect(result.$2, isNull);
    });
  });
}
