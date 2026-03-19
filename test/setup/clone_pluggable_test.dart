/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:gitjournal/setup/clone.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('cloneRemotePluggable clones when repo path does not exist', () async {
    final tempDir = await Directory.systemTemp.createTemp('gj_clone_test_');
    final repoPath = p.join(tempDir.path, 'missing_repo');

    var cloneCalled = false;
    var fetchCalled = false;

    await cloneRemotePluggable(
      repoPath: repoPath,
      cloneUrl: 'git@example.com:demo/repo.git',
      remoteName: 'origin',
      sshPublicKey: '',
      sshPrivateKey: '',
      sshPassword: '',
      authorName: 'Author',
      authorEmail: 'author@example.com',
      progressUpdate: (_) {},
      gitFetchFn: (_, __, ___, ____, _____, ______) async {
        fetchCalled = true;
      },
      gitCloneFn: ({
        required String cloneUrl,
        required String repoPath,
        required String sshPublicKey,
        required String sshPrivateKey,
        required String sshPassword,
        required String statusFile,
      }) async {
        cloneCalled = true;
      },
      defaultBranchFn: (_, __, ___, ____, _____) async => 'main',
    );

    expect(cloneCalled, isTrue);
    expect(fetchCalled, isFalse);
  });

  test('cloneRemotePluggable deletes .git-only repo before clone', () async {
    final tempDir = await Directory.systemTemp.createTemp('gj_clone_test_');
    final repoPath = p.join(tempDir.path, 'repo');
    final repoDir = Directory(repoPath)..createSync(recursive: true);
    Directory(p.join(repoDir.path, '.git')).createSync(recursive: true);

    var repoPathExistsAtCloneStart = true;

    await cloneRemotePluggable(
      repoPath: repoPath,
      cloneUrl: 'git@example.com:demo/repo.git',
      remoteName: 'origin',
      sshPublicKey: '',
      sshPrivateKey: '',
      sshPassword: '',
      authorName: 'Author',
      authorEmail: 'author@example.com',
      progressUpdate: (_) {},
      gitFetchFn: (_, __, ___, ____, _____, ______) async {},
      gitCloneFn: ({
        required String cloneUrl,
        required String repoPath,
        required String sshPublicKey,
        required String sshPrivateKey,
        required String sshPassword,
        required String statusFile,
      }) async {
        repoPathExistsAtCloneStart = Directory(repoPath).existsSync();
      },
      defaultBranchFn: (_, __, ___, ____, _____) async => 'main',
    );

    expect(repoPathExistsAtCloneStart, isFalse);
  });

  test('cloneRemotePluggable retries once on tmp_pack rename failure', () async {
    final tempDir = await Directory.systemTemp.createTemp('gj_clone_test_');
    final repoPath = p.join(tempDir.path, 'repo_retry');

    var cloneCalls = 0;

    await cloneRemotePluggable(
      repoPath: repoPath,
      cloneUrl: 'git@example.com:demo/repo.git',
      remoteName: 'origin',
      sshPublicKey: '',
      sshPrivateKey: '',
      sshPassword: '',
      authorName: 'Author',
      authorEmail: 'author@example.com',
      progressUpdate: (_) {},
      gitFetchFn: (_, __, ___, ____, _____, ______) async {},
      gitCloneFn: ({
        required String cloneUrl,
        required String repoPath,
        required String sshPublicKey,
        required String sshPrivateKey,
        required String sshPassword,
        required String statusFile,
      }) async {
        cloneCalls += 1;
        if (cloneCalls == 1) {
          throw Exception(
            'GitClone failed with error: rename /tmp/.git/objects/pack/tmp_pack_123 /tmp/.git/objects/pack/pack-1.pack',
          );
        }
      },
      defaultBranchFn: (_, __, ___, ____, _____) async => 'main',
    );

    expect(cloneCalls, 2);
  });

}
