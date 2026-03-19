/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/startup/display_mode.dart';
import 'package:gitjournal/startup/startup_trace.dart';
import 'package:gitjournal/utils/bloc_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  Chain.capture(() async {
    await _main();
  }, onError: (Object error, Chain chain) async {
    await reportError(error, chain.toTrace());
    runApp(_StartupFailureApp(error: error.toString()));
  });
}

Future<void> _main() async {
  final startupTrace = StartupTrace('main');
  startupTrace.mark('enter');
  BindingBase.debugZoneErrorsAreFatal = true;
  Bloc.observer = GlobalBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  startupTrace.mark('widgets binding initialized');

  var pref = await SharedPreferences.getInstance();
  startupTrace.mark('shared preferences loaded');
  AppConfig.instance.load(pref);
  startupTrace.mark('app config loaded');

  FlutterError.onError = flutterOnErrorHandler;

  Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
    var isolateError = pair as List<dynamic>;
    assert(isolateError.length == 2);
    assert(isolateError.first.runtimeType == Error);
    assert(isolateError.last.runtimeType == StackTrace);

    await reportError(isolateError.first, isolateError.last);
  }).sendPort);

  setHighRefreshRateInBackground(
    isMobile: Platform.isIOS || Platform.isAndroid,
    setHighRefreshRate: FlutterDisplayMode.setHighRefreshRate,
    reportErrorFn: reportError,
  );
  startupTrace.mark('display mode task scheduled');

  await JournalApp.main(
    pref,
    startupTrace: startupTrace,
  ).timeout(const Duration(seconds: 240));
  startupTrace.finish('JournalApp.main completed');
}

class _StartupFailureApp extends StatelessWidget {
  final String error;

  const _StartupFailureApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                "GitJournal failed to start.\n\n$error",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
