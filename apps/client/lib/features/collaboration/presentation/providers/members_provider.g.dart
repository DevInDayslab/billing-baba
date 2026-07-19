// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Members)
final membersProvider = MembersProvider._();

final class MembersProvider
    extends $AsyncNotifierProvider<Members, List<BusinessMember>> {
  MembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membersHash();

  @$internal
  @override
  Members create() => Members();
}

String _$membersHash() => r'eeb5ba9ae7f99dc7251676b6290a4f64781279f4';

abstract class _$Members extends $AsyncNotifier<List<BusinessMember>> {
  FutureOr<List<BusinessMember>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BusinessMember>>, List<BusinessMember>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BusinessMember>>,
                List<BusinessMember>
              >,
              AsyncValue<List<BusinessMember>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
