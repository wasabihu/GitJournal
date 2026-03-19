/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

typedef BuildFastRepo = Future<void> Function();
typedef CurrentRepoGetter<T> = T? Function();
typedef RepoTask<T> = Future<void> Function(T repo);
typedef RepoErrorHandler = Future<void> Function(
  String stage,
  Object error,
  StackTrace st,
);

Future<void> runRepoFastStartFlow<T>({
  required BuildFastRepo buildFastRepo,
  required CurrentRepoGetter<T> currentRepo,
  required RepoTask<T> reloadNotes,
  required RepoTask<T> syncNotes,
  required RepoErrorHandler onError,
}) async {
  await buildFastRepo();

  final repo = currentRepo();
  if (repo == null) {
    return;
  }

  unawaited(
    _runRepoTask(
      stage: 'reloadNotes',
      repo: repo,
      task: reloadNotes,
      onError: onError,
    ),
  );
  unawaited(
    _runRepoTask(
      stage: 'syncNotes',
      repo: repo,
      task: syncNotes,
      onError: onError,
    ),
  );
}

Future<void> _runRepoTask<T>({
  required String stage,
  required T repo,
  required RepoTask<T> task,
  required RepoErrorHandler onError,
}) async {
  try {
    await task(repo);
  } catch (ex, st) {
    await onError(stage, ex, st);
  }
}

