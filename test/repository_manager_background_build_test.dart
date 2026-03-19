import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestRepositoryManager extends RepositoryManager {
  _TestRepositoryManager({
    required super.pref,
    required this.buildFutureFactory,
  }) : super(
          gitBaseDir: 'tmp_git',
          cacheDir: 'tmp_cache',
        );

  final Future<GitJournalRepo?> Function({
    required bool loadFromCache,
    required bool syncOnBoot,
    required bool checkExternalChangesOnLoad,
    required bool fastStartupMode,
  }) buildFutureFactory;

  int buildCallCount = 0;
  bool? capturedLoadFromCache;
  bool? capturedSyncOnBoot;
  bool? capturedCheckExternalChangesOnLoad;
  bool? capturedFastStartupMode;

  @override
  Future<GitJournalRepo?> buildActiveRepository({
    bool loadFromCache = true,
    bool syncOnBoot = true,
    bool checkExternalChangesOnLoad = true,
    bool fastStartupMode = false,
  }) {
    buildCallCount += 1;
    capturedLoadFromCache = loadFromCache;
    capturedSyncOnBoot = syncOnBoot;
    capturedCheckExternalChangesOnLoad = checkExternalChangesOnLoad;
    capturedFastStartupMode = fastStartupMode;

    return buildFutureFactory(
      loadFromCache: loadFromCache,
      syncOnBoot: syncOnBoot,
      checkExternalChangesOnLoad: checkExternalChangesOnLoad,
      fastStartupMode: fastStartupMode,
    );
  }
}

void main() {
  test('buildActiveRepositoryInBackground forwards build flags', () async {
    SharedPreferences.setMockInitialValues({});
    final pref = await SharedPreferences.getInstance();

    final completer = Completer<GitJournalRepo?>();
    final repoManager = _TestRepositoryManager(
      pref: pref,
      buildFutureFactory: ({
        required loadFromCache,
        required syncOnBoot,
        required checkExternalChangesOnLoad,
        required fastStartupMode,
      }) {
        return completer.future;
      },
    );

    repoManager.buildActiveRepositoryInBackground(
      loadFromCache: false,
      syncOnBoot: false,
      checkExternalChangesOnLoad: false,
      fastStartupMode: true,
      timeout: const Duration(seconds: 1),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(repoManager.buildCallCount, 1);
    expect(repoManager.capturedLoadFromCache, isFalse);
    expect(repoManager.capturedSyncOnBoot, isFalse);
    expect(repoManager.capturedCheckExternalChangesOnLoad, isFalse);
    expect(repoManager.capturedFastStartupMode, isTrue);

    completer.complete(null);
  });

  test('buildActiveRepositoryInBackground sets timeout error', () async {
    SharedPreferences.setMockInitialValues({});
    final pref = await SharedPreferences.getInstance();

    final neverCompleting = Completer<GitJournalRepo?>();
    final repoManager = _TestRepositoryManager(
      pref: pref,
      buildFutureFactory: ({
        required loadFromCache,
        required syncOnBoot,
        required checkExternalChangesOnLoad,
        required fastStartupMode,
      }) {
        return neverCompleting.future;
      },
    );

    repoManager.buildActiveRepositoryInBackground(
      timeout: const Duration(milliseconds: 20),
    );

    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(repoManager.currentRepoError, isA<TimeoutException>());
  });

  test('buildActiveRepositoryInBackground captures thrown errors', () async {
    SharedPreferences.setMockInitialValues({});
    final pref = await SharedPreferences.getInstance();

    final repoManager = _TestRepositoryManager(
      pref: pref,
      buildFutureFactory: ({
        required loadFromCache,
        required syncOnBoot,
        required checkExternalChangesOnLoad,
        required fastStartupMode,
      }) {
        throw StateError('boom');
      },
    );

    repoManager.buildActiveRepositoryInBackground(
      timeout: const Duration(seconds: 1),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repoManager.currentRepoError, isA<StateError>());
  });
}
