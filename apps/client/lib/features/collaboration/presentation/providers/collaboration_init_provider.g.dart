// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_init_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollaborationInit)
final collaborationInitProvider = CollaborationInitProvider._();

final class CollaborationInitProvider
    extends $AsyncNotifierProvider<CollaborationInit, void> {
  CollaborationInitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationInitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationInitHash();

  @$internal
  @override
  CollaborationInit create() => CollaborationInit();
}

String _$collaborationInitHash() => r'f9e424320dfeb72f93f90b96a6759b4786b07548';

abstract class _$CollaborationInit extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
