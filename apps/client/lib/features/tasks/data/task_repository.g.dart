// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoMasterRepository)
final todoMasterRepositoryProvider = TodoMasterRepositoryProvider._();

final class TodoMasterRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodoMasterRepository>,
          TodoMasterRepository,
          FutureOr<TodoMasterRepository>
        >
    with
        $FutureModifier<TodoMasterRepository>,
        $FutureProvider<TodoMasterRepository> {
  TodoMasterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoMasterRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoMasterRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<TodoMasterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TodoMasterRepository> create(Ref ref) {
    return todoMasterRepository(ref);
  }
}

String _$todoMasterRepositoryHash() =>
    r'34385737a42b33c238cb4f13af3da5d19a0b3b86';

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TaskRepository>,
          TaskRepository,
          FutureOr<TaskRepository>
        >
    with $FutureModifier<TaskRepository>, $FutureProvider<TaskRepository> {
  TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<TaskRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TaskRepository> create(Ref ref) {
    return taskRepository(ref);
  }
}

String _$taskRepositoryHash() => r'4808e1d1b7d76e54f9c3ab2e904522f9bcb35094';
