import 'dart:io';

import 'package:billing_baba/features/search/providers/search_dialog_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut intents for opening the search dialog.
class OpenSearchDialogIntent extends Intent {
  const OpenSearchDialogIntent();
}

/// Builds shell-level shortcuts for the search command palette.
Map<ShortcutActivator, Intent> buildSearchShortcuts() {
  final modifier = Platform.isMacOS;
  return {
    SingleActivator(
      LogicalKeyboardKey.keyK,
      meta: modifier,
      control: !modifier,
    ): const OpenSearchDialogIntent(),
    SingleActivator(
      LogicalKeyboardKey.keyF,
      meta: modifier,
      control: !modifier,
    ): const OpenSearchDialogIntent(),
  };
}

/// Opens the search dialog via the registered controller.
void openSearchDialogFromShell(
  BuildContext context,
  SearchDialogNotifier notifier,
) {
  notifier.open(context);
}
