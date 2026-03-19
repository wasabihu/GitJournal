/*
 * SPDX-FileCopyrightText: 2023 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';

class FolderViewConfigurationDialog extends StatelessWidget {
  final StandardViewHeader headerType;
  final bool showSummary;

  final void Function(StandardViewHeader?) onHeaderTypeChanged;
  final void Function(bool) onShowSummaryChanged;

  const FolderViewConfigurationDialog({
    super.key,
    required this.headerType,
    required this.showSummary,
    required this.onHeaderTypeChanged,
    required this.onShowSummaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FolderViewConfigurationDialogBody(
      headerType: headerType,
      showSummary: showSummary,
      onHeaderTypeChanged: onHeaderTypeChanged,
      onShowSummaryChanged: onShowSummaryChanged,
    );
  }
}

class _FolderViewConfigurationDialogBody extends StatefulWidget {
  final StandardViewHeader headerType;
  final bool showSummary;

  final void Function(StandardViewHeader?) onHeaderTypeChanged;
  final void Function(bool) onShowSummaryChanged;

  const _FolderViewConfigurationDialogBody({
    required this.headerType,
    required this.showSummary,
    required this.onHeaderTypeChanged,
    required this.onShowSummaryChanged,
  });

  @override
  State<_FolderViewConfigurationDialogBody> createState() =>
      _FolderViewConfigurationDialogBodyState();
}

class _FolderViewConfigurationDialogBodyState
    extends State<_FolderViewConfigurationDialogBody> {
  late StandardViewHeader _headerType;
  late bool _showSummary;

  @override
  void initState() {
    super.initState();
    _headerType = widget.headerType;
    _showSummary = widget.showSummary;
  }

  @override
  void didUpdateWidget(covariant _FolderViewConfigurationDialogBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headerType != widget.headerType) {
      _headerType = widget.headerType;
    }
    if (oldWidget.showSummary != widget.showSummary) {
      _showSummary = widget.showSummary;
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      SettingsHeader(context.loc.widgetsFolderViewHeaderOptionsHeading),
      RadioListTile<StandardViewHeader>(
        title: Text(context.loc.widgetsFolderViewHeaderOptionsTitleFileName),
        value: StandardViewHeader.TitleOrFileName,
        groupValue: _headerType,
        onChanged: _headerTypeChanged,
      ),
      RadioListTile<StandardViewHeader>(
        title: Text(context.loc.widgetsFolderViewHeaderOptionsAuto),
        value: StandardViewHeader.TitleGenerated,
        groupValue: _headerType,
        onChanged: _headerTypeChanged,
      ),
      RadioListTile<StandardViewHeader>(
        key: const ValueKey("ShowFileNameOnly"),
        title: Text(context.loc.widgetsFolderViewHeaderOptionsFileName),
        value: StandardViewHeader.FileName,
        groupValue: _headerType,
        onChanged: _headerTypeChanged,
      ),
      SwitchListTile(
        key: const ValueKey("SummaryToggle"),
        title: Text(context.loc.widgetsFolderViewHeaderOptionsSummary),
        value: _showSummary,
        onChanged: _showSummaryChanged,
      ),
    ];

    return AlertDialog(
      title: GestureDetector(
        key: const ValueKey("Hack_Back"),
        child: Text(context.loc.widgetsFolderViewHeaderOptionsCustomize),
        onTap: () {
          // Hack to get out of the dialog in the tests
          // driver.findByType('ModalBarrier') doesn't seem to be working
          if (foundation.kDebugMode) {
            Navigator.of(context).pop();
          }
        },
      ),
      key: const ValueKey("ViewOptionsDialog"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _headerTypeChanged(StandardViewHeader? newHeader) {
    if (newHeader == null) {
      return;
    }
    setState(() {
      _headerType = newHeader;
    });
    widget.onHeaderTypeChanged(newHeader);
  }

  void _showSummaryChanged(bool newVal) {
    setState(() {
      _showSummary = newVal;
    });
    widget.onShowSummaryChanged(newVal);
  }
}
