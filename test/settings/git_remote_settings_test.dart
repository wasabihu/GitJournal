/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:git_setup/keygen.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  test('applyGeneratedSshKeyToConfig stores the private key correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final pref = await SharedPreferences.getInstance();
    final config = GitConfig('test', pref);

    const sshKey = SshKey(
      publicKey: 'ssh-rsa AAAAB3Nza test@example',
      privateKey: '-----BEGIN PRIVATE KEY-----',
      password: 'secret',
      type: SshKeyType.Rsa,
    );

    await applyGeneratedSshKeyToConfig(config: config, sshKey: sshKey);

    expect(config.sshPublicKey, sshKey.publicKey);
    expect(config.sshPrivateKey, sshKey.privateKey);
    expect(config.sshPassword, sshKey.password);
  });
}
