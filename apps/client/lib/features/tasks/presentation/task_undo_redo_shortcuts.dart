import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskCompletionUndoIntent extends Intent {
  const TaskCompletionUndoIntent();
}

class TaskCompletionRedoIntent extends Intent {
  const TaskCompletionRedoIntent();
}

Map<ShortcutActivator, Intent> buildTaskCompletionUndoRedoShortcuts() {
  final useMeta = AppPlatform.current.isMacOS;
  return {
    SingleActivator(
      LogicalKeyboardKey.keyZ,
      meta: useMeta,
      control: !useMeta,
    ): const TaskCompletionUndoIntent(),
    if (useMeta)
      const SingleActivator(
        LogicalKeyboardKey.keyZ,
        meta: true,
        shift: true,
      ): const TaskCompletionRedoIntent()
    else ...{
      const SingleActivator(
        LogicalKeyboardKey.keyY,
        control: true,
      ): const TaskCompletionRedoIntent(),
      const SingleActivator(
        LogicalKeyboardKey.keyZ,
        control: true,
        shift: true,
      ): const TaskCompletionRedoIntent(),
    },
  };
}

/// Same rules as navigation search — do not steal undo from text fields.
bool shouldSuppressTaskCompletionUndoRedoShortcuts() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus == null) return false;

  final context = focus.context;
  if (context == null) return false;

  return context.widget is EditableText ||
      context.findAncestorStateOfType<EditableTextState>() != null;
}

String taskCompletionUndoShortcutLabel() {
  if (AppPlatform.current.isMacOS) return '⌘Z';
  return 'Ctrl+Z';
}

String taskCompletionRedoShortcutLabel() {
  if (AppPlatform.current.isMacOS) return '⌘⇧Z';
  return 'Ctrl+Y';
}
