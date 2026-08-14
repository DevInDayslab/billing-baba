// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskFilterState)
final taskFilterStateProvider = TaskFilterStateProvider._();

final class TaskFilterStateProvider
    extends $NotifierProvider<TaskFilterState, TaskFilter> {
  TaskFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskFilterStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskFilterStateHash();

  @$internal
  @override
  TaskFilterState create() => TaskFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskFilter>(value),
    );
  }
}

String _$taskFilterStateHash() => r'b664a951cd1d3ae067e64ef86c520ac45c89ce0a';

abstract class _$TaskFilterState extends $Notifier<TaskFilter> {
  TaskFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaskFilter, TaskFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskFilter, TaskFilter>,
              TaskFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Tasks)
final tasksProvider = TasksProvider._();

final class TasksProvider
    extends $AsyncNotifierProvider<Tasks, List<TaskModel>> {
  TasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksHash();

  @$internal
  @override
  Tasks create() => Tasks();
}

String _$tasksHash() => r'82b069218903c90809331378c18138541b0c1aa1';

abstract class _$Tasks extends $AsyncNotifier<List<TaskModel>> {
  FutureOr<List<TaskModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TaskModel>>, List<TaskModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TaskModel>>, List<TaskModel>>,
              AsyncValue<List<TaskModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredTasks)
final filteredTasksProvider = FilteredTasksProvider._();

final class FilteredTasksProvider
    extends
        $FunctionalProvider<List<TaskModel>, List<TaskModel>, List<TaskModel>>
    with $Provider<List<TaskModel>> {
  FilteredTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTasksHash();

  @$internal
  @override
  $ProviderElement<List<TaskModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskModel> create(Ref ref) {
    return filteredTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskModel>>(value),
    );
  }
}

String _$filteredTasksHash() => r'e0a5a513377d6f94a47f3de7d1d531c36a2fb21a';
