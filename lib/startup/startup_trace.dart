/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

typedef StartupTraceSink = void Function(String message);

void emitStartupTrace(String message, {String name = 'startup'}) {
  final line = 'StartupTrace[$name] $message';
  debugPrint(line);
  developer.log(line, name: 'gitjournal.startup');
}

class StartupTrace {
  final String name;
  final StartupTraceSink _sink;
  final Stopwatch _stopwatch = Stopwatch()..start();

  StartupTrace(this.name, {StartupTraceSink? sink})
      : _sink = sink ?? ((msg) => emitStartupTrace(msg, name: 'main'));

  int mark(String step) {
    final ms = _stopwatch.elapsedMilliseconds;
    _sink('[$name] +${ms}ms: $step');
    return ms;
  }

  int finish([String step = 'done']) {
    final ms = mark(step);
    _stopwatch.stop();
    return ms;
  }
}
