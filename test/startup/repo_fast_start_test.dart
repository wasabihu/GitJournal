import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/startup/repo_fast_start.dart';

class _FakeRepo {
  int reloadCalls = 0;
  int syncCalls = 0;

  Future<void> reloadNotes() async {
    reloadCalls += 1;
  }

  Future<void> syncNotes() async {
    syncCalls += 1;
  }
}

void main() {
  test('runRepoFastStartFlow builds fast and schedules warmup tasks', () async {
    final repo = _FakeRepo();
    var buildCalls = 0;

    await runRepoFastStartFlow<_FakeRepo>(
      buildFastRepo: () async {
        buildCalls += 1;
      },
      currentRepo: () => repo,
      reloadNotes: (r) => r.reloadNotes(),
      syncNotes: (r) => r.syncNotes(),
      onError: (_, __, ___) async {},
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(buildCalls, 1);
    expect(repo.reloadCalls, 1);
    expect(repo.syncCalls, 1);
  });

  test('runRepoFastStartFlow skips warmup when repo is null', () async {
    var buildCalls = 0;
    var taskCalls = 0;

    await runRepoFastStartFlow<Object>(
      buildFastRepo: () async {
        buildCalls += 1;
      },
      currentRepo: () => null,
      reloadNotes: (_) async {
        taskCalls += 1;
      },
      syncNotes: (_) async {
        taskCalls += 1;
      },
      onError: (_, __, ___) async {},
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(buildCalls, 1);
    expect(taskCalls, 0);
  });
}
