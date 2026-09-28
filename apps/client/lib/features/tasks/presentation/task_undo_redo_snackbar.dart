import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/application/task_completion_undo_redo_provider.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/task_undo_redo_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Action link color on dark toasts (Google Sheets–style).
const _sheetsActionColor = Color(0xFF8AB4F8);

const _sheetsSnackMargin = EdgeInsets.fromLTRB(
  AppSpacing.lg,
  0,
  AppSpacing.lg,
  AppSpacing.xl,
);

/// Short toast; [SnackBarAction] defaults `persist` to true (no auto-dismiss).
const _completionSnackDuration = Duration(seconds: 3);

/// Shows a floating undo toast after marking a reminder complete.
void showTaskCompletionUndoRedoSnackBar({
  required BuildContext context,
  required WidgetRef ref,
  required TaskModel snapshotBeforeComplete,
}) {
  ref
      .read(taskCompletionUndoRedoProvider.notifier)
      .recordCompletion(snapshotBeforeComplete);

  _showSheetsStyleSnackBar(
    context: context,
    message: 'Reminder completed',
    actionLabel: 'Undo',
    onAction: () => performTaskCompletionUndo(context: context, ref: ref),
  );
}

void performTaskCompletionUndo({
  required BuildContext context,
  required WidgetRef ref,
}) {
  unawaited(() async {
    final snapshot = await ref
        .read(taskCompletionUndoRedoProvider.notifier)
        .undo(ref.read(tasksProvider.notifier));
    if (snapshot == null || !context.mounted) return;

    _showSheetsStyleSnackBar(
      context: context,
      message: 'Change undone',
      actionLabel: 'Redo',
      onAction: () => performTaskCompletionRedo(context: context, ref: ref),
    );
  }());
}

void performTaskCompletionRedo({
  required BuildContext context,
  required WidgetRef ref,
}) {
  unawaited(() async {
    final previous = await ref
        .read(taskCompletionUndoRedoProvider.notifier)
        .redo(ref.read(tasksProvider.notifier));
    if (previous == null || !context.mounted) return;
    if (!previous.isCompleted) {
      showTaskCompletionUndoRedoSnackBar(
        context: context,
        ref: ref,
        snapshotBeforeComplete: previous,
      );
    }
  }());
}

/// Edit menu: task undo when available, else false.
bool tryTaskCompletionUndo(WidgetRef ref, BuildContext context) {
  if (shouldSuppressTaskCompletionUndoRedoShortcuts()) return false;
  if (!ref.read(taskCompletionUndoRedoProvider).canUndo) return false;
  performTaskCompletionUndo(context: context, ref: ref);
  return true;
}

/// Edit menu: task redo when available, else false.
bool tryTaskCompletionRedo(WidgetRef ref, BuildContext context) {
  if (shouldSuppressTaskCompletionUndoRedoShortcuts()) return false;
  if (!ref.read(taskCompletionUndoRedoProvider).canRedo) return false;
  performTaskCompletionRedo(context: context, ref: ref);
  return true;
}

void _showSheetsStyleSnackBar({
  required BuildContext context,
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: _sheetsSnackMargin,
      duration: _completionSnackDuration,
      persist: false,
      action: SnackBarAction(
        label: actionLabel,
        textColor: _sheetsActionColor,
        onPressed: () {
          messenger.hideCurrentSnackBar();
          onAction();
        },
      ),
    ),
  );

  unawaited(
    Future<void>.delayed(_completionSnackDuration, controller.close),
  );
}
