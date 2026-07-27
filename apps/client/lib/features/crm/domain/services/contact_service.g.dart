// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactService)
final contactServiceProvider = ContactServiceProvider._();

final class ContactServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContactService>,
          ContactService,
          FutureOr<ContactService>
        >
    with $FutureModifier<ContactService>, $FutureProvider<ContactService> {
  ContactServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactServiceHash();

  @$internal
  @override
  $FutureProviderElement<ContactService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContactService> create(Ref ref) {
    return contactService(ref);
  }
}

String _$contactServiceHash() => r'78848ae4713770f642bf601b3d32704f7b75b240';
