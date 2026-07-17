// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContactDetail)
final contactDetailProvider = ContactDetailFamily._();

final class ContactDetailProvider
    extends $StreamNotifierProvider<ContactDetail, ContactWithActivities?> {
  ContactDetailProvider._({
    required ContactDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contactDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contactDetailHash();

  @override
  String toString() {
    return r'contactDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ContactDetail create() => ContactDetail();

  @override
  bool operator ==(Object other) {
    return other is ContactDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contactDetailHash() => r'09e0ea04fcbf3865fe040a0512475ea8d358513d';

final class ContactDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          ContactDetail,
          AsyncValue<ContactWithActivities?>,
          ContactWithActivities?,
          Stream<ContactWithActivities?>,
          String
        > {
  ContactDetailFamily._()
    : super(
        retry: null,
        name: r'contactDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ContactDetailProvider call(String contactId) =>
      ContactDetailProvider._(argument: contactId, from: this);

  @override
  String toString() => r'contactDetailProvider';
}

abstract class _$ContactDetail extends $StreamNotifier<ContactWithActivities?> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  Stream<ContactWithActivities?> build(String contactId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ContactWithActivities?>, ContactWithActivities?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ContactWithActivities?>,
                ContactWithActivities?
              >,
              AsyncValue<ContactWithActivities?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
