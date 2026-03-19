/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/foundation.dart';

typedef SetHighRefreshRateFn = Future<void> Function();
typedef ReportErrorFn = Future<void> Function(Object error, StackTrace st);

Future<void> setHighRefreshRateSafely({
  required bool isMobile,
  required SetHighRefreshRateFn setHighRefreshRate,
  required ReportErrorFn reportErrorFn,
  Duration timeout = const Duration(seconds: 3),
}) async {
  if (!isMobile) {
    return;
  }

  try {
    await setHighRefreshRate().timeout(timeout);
  } catch (ex, st) {
    debugPrint("Failed to set high refresh rate: $ex");
    await reportErrorFn(
      Exception("Failed to set high refresh rate: $ex"),
      st,
    );
  }
}

void setHighRefreshRateInBackground({
  required bool isMobile,
  required SetHighRefreshRateFn setHighRefreshRate,
  required ReportErrorFn reportErrorFn,
  Duration timeout = const Duration(seconds: 3),
}) {
  unawaited(
    setHighRefreshRateSafely(
      isMobile: isMobile,
      setHighRefreshRate: setHighRefreshRate,
      reportErrorFn: reportErrorFn,
      timeout: timeout,
    ),
  );
}

