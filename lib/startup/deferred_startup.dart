/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

typedef AsyncTask = Future<void> Function();
typedef SyncTask = void Function();
typedef ErrorReporter = Future<void> Function(Object error, StackTrace st);

Future<void> runDeferredStartupTasks({
  required AsyncTask initLog,
  required AsyncTask initAnalytics,
  required SyncTask confirmPurchase,
  required ErrorReporter reportErrorFn,
}) async {
  try {
    await initLog();
  } catch (ex, st) {
    await reportErrorFn(Exception('Failed to initialize startup logs: $ex'), st);
  }

  try {
    await initAnalytics();
  } catch (ex, st) {
    await reportErrorFn(Exception('Failed to initialize analytics: $ex'), st);
  }

  try {
    confirmPurchase();
  } catch (ex, st) {
    await reportErrorFn(Exception('Failed to confirm startup purchase state: $ex'), st);
  }
}
