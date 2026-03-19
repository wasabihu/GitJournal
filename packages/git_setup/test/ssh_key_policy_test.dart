/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:git_setup/keygen.dart';
import 'package:git_setup/ssh_key_policy.dart';
import 'package:test/test.dart';

void main() {
  test('keeps configured key type on non-Android', () {
    expect(
      autoConfigureKeyType(
        configuredType: SshKeyType.Ed25519,
        isAndroid: false,
      ),
      SshKeyType.Ed25519,
    );
  });

  test('switches Ed25519 to RSA on Android', () {
    expect(
      autoConfigureKeyType(
        configuredType: SshKeyType.Ed25519,
        isAndroid: true,
      ),
      SshKeyType.Rsa,
    );
  });

  test('keeps RSA on Android', () {
    expect(
      autoConfigureKeyType(
        configuredType: SshKeyType.Rsa,
        isAndroid: true,
      ),
      SshKeyType.Rsa,
    );
  });
}
