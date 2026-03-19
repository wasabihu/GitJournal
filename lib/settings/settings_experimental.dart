/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:provider/provider.dart';

class ExperimentalSettingsScreen extends StatefulWidget {
  static const routePath = '/settings/experimental';

  @override
  _ExperimentalSettingsScreenState createState() =>
      _ExperimentalSettingsScreenState();
}

class _ExperimentalSettingsScreenState
    extends State<ExperimentalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var appConfig = context.watch<AppConfig>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsExperimentalTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          children: <Widget>[
            const Center(
              child: Icon(CommunityMaterialIcons.flask, size: 64 * 2),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalIncludeSubfolders),
              value: appConfig.experimentalSubfolders,
              onChanged: (bool newVal) {
                appConfig.experimentalSubfolders = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalMarkdownToolbar),
              value: appConfig.experimentalMarkdownToolbar,
              onChanged: (bool newVal) {
                appConfig.experimentalMarkdownToolbar = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalAccounts),
              value: appConfig.experimentalAccounts,
              onChanged: (bool newVal) {
                appConfig.experimentalAccounts = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalAutoCompleteTags),
              value: appConfig.experimentalTagAutoCompletion,
              onChanged: (bool newVal) {
                appConfig.experimentalTagAutoCompletion = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            if (!foundation.kReleaseMode)
              SwitchListTile(
                title: const Text('Force Pro Mode (Dev)'),
                subtitle: Text(
                  appConfig.proMode
                      ? 'Enabled for this install'
                      : 'Disabled for this install',
                ),
                value: appConfig.proMode && !appConfig.validateProMode,
                onChanged: (bool enabled) {
                  appConfig.validateProMode = !enabled;
                  appConfig.proMode = enabled;
                  appConfig.save();
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }
}
