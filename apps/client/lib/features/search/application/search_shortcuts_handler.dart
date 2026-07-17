import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut intent for opening the navigation search dialog.
class OpenSearchDialogIntent extends Intent {
  const OpenSearchDialogIntent();
}

/// Builds the single shell-level shortcut for navigation search.
Map<ShortcutActivator, Intent> buildSearchShortcuts() {
  final useMeta = Platform.isMacOS;
  return {
    SingleActivator(
      LogicalKeyboardKey.keyF,
      meta: useMeta,
      control: !useMeta,
    ): const OpenSearchDialogIntent(),
  };
}

/// Returns true when the search shortcut should be ignored.
bool shouldSuppressSearchShortcuts() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus == null) return false;

  final context = focus.context;
  if (context == null) return false;

  return context.widget is EditableText ||
      context.findAncestorStateOfType<EditableTextState>() != null;
}
