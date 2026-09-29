// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_completion_undo_redo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Last task completion undo/redo (Google Sheets–style, single step).

@ProviderFor(TaskCompletionUndoRedo)
final taskCompletionUndoRedoProvider = TaskCompletionUndoRedoProvider._();

/// Last task completion undo/redo (Google Sheets–style, single step).
final class TaskCompletionUndoRedoProvider
    extends
        $NotifierProvider<TaskCompletionUndoRedo, TaskCompletionUndoRedoState> {
  /// Last task completion undo/redo (Google Sheets–style, single step).
  TaskCompletionUndoRedoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskCompletionUndoRedoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskCompletionUndoRedoHash();

  @$internal
  @override
  TaskCompletionUndoRedo create() => TaskCompletionUndoRedo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskCompletionUndoRedoState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskCompletionUndoRedoState>(value),
    );
  }
}

String _$taskCompletionUndoRedoHash() =>
    r'd9599406e29fb3c573d599313192f415bba39377';

/// Last task completion undo/redo (Google Sheets–style, single step).

abstract class _$TaskCompletionUndoRedo
    extends $Notifier<TaskCompletionUndoRedoState> {
  TaskCompletionUndoRedoState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<TaskCompletionUndoRedoState, TaskCompletionUndoRedoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                TaskCompletionUndoRedoState,
                TaskCompletionUndoRedoState
              >,
              TaskCompletionUndoRedoState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
