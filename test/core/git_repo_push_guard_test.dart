/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/git_repo.dart';
import 'package:test/test.dart';

void main() {
  test('skip push when there are no outgoing changes', () {
    expect(shouldSkipPushWhenNoOutgoingChanges(0), isTrue);
  });

  test('do not skip push when there are outgoing changes', () {
    expect(shouldSkipPushWhenNoOutgoingChanges(1), isFalse);
  });

  test('skip push when local branch is behind or equal', () {
    expect(shouldSkipPushWhenNoOutgoingChanges(-1), isTrue);
  });
}
