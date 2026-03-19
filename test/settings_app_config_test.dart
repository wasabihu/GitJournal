/*
 * SPDX-FileCopyrightText: 2026
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppConfig loads with Pro unlocked by default', () async {
    SharedPreferences.setMockInitialValues({
      'proMode': false,
      'validateProMode': true,
    });

    final pref = await SharedPreferences.getInstance();
    final appConfig = AppConfig.instance;

    appConfig.proMode = false;
    appConfig.validateProMode = true;
    appConfig.load(pref);

    expect(appConfig.proMode, isTrue);
    expect(appConfig.validateProMode, isFalse);
  });
}
