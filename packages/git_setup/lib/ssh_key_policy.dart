/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:git_setup/keygen.dart';

SshKeyType autoConfigureKeyType({
  required SshKeyType configuredType,
  required bool isAndroid,
}) {
  if (!isAndroid) {
    return configuredType;
  }

  // go_git_dart can fail with "function not implemented" for Ed25519 on
  // some Android environments. Prefer RSA for auto-configure stability.
  if (configuredType == SshKeyType.Ed25519) {
    return SshKeyType.Rsa;
  }

  return configuredType;
}
