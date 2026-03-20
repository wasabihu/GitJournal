/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:git_setup/clone_url.dart';
import 'package:test/test.dart';

void main() {
  group('isSupportedCloneUrlProtocol', () {
    test('accepts ssh', () {
      expect(isSupportedCloneUrlProtocol('ssh'), isTrue);
    });

    test('accepts https', () {
      expect(isSupportedCloneUrlProtocol('https'), isTrue);
    });

    test('accepts http', () {
      expect(isSupportedCloneUrlProtocol('http'), isTrue);
    });

    test('rejects unsupported protocols', () {
      expect(isSupportedCloneUrlProtocol('ftp'), isFalse);
      expect(isSupportedCloneUrlProtocol('file'), isFalse);
    });
  });
}
