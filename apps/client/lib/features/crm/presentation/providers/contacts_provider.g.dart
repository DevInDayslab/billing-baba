// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Contacts)
final contactsProvider = ContactsProvider._();

final class ContactsProvider
    extends $AsyncNotifierProvider<Contacts, List<Contact>> {
  ContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsHash();

  @$internal
  @override
  Contacts create() => Contacts();
}

String _$contactsHash() => r'cac25e13deeff445b0c3d615d71beebb994de39c';

abstract class _$Contacts extends $AsyncNotifier<List<Contact>> {
  FutureOr<List<Contact>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Contact>>, List<Contact>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Contact>>, List<Contact>>,
              AsyncValue<List<Contact>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredContactsList)
final filteredContactsListProvider = FilteredContactsListProvider._();

final class FilteredContactsListProvider
    extends $FunctionalProvider<List<Contact>, List<Contact>, List<Contact>>
    with $Provider<List<Contact>> {
  FilteredContactsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredContactsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredContactsListHash();

  @$internal
  @override
  $ProviderElement<List<Contact>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Contact> create(Ref ref) {
    return filteredContactsList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Contact> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Contact>>(value),
    );
  }
}

String _$filteredContactsListHash() =>
    r'd089dbef80de5be29c072a14bfd9043d609bdec4';

@ProviderFor(sortedContactsList)
final sortedContactsListProvider = SortedContactsListProvider._();

final class SortedContactsListProvider
    extends $FunctionalProvider<List<Contact>, List<Contact>, List<Contact>>
    with $Provider<List<Contact>> {
  SortedContactsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedContactsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedContactsListHash();

  @$internal
  @override
  $ProviderElement<List<Contact>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Contact> create(Ref ref) {
    return sortedContactsList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Contact> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Contact>>(value),
    );
  }
}

String _$sortedContactsListHash() =>
    r'9c68172be9bfc720c549b8965b290545941cb6ee';

@ProviderFor(paginatedContacts)
final paginatedContactsProvider = PaginatedContactsProvider._();

final class PaginatedContactsProvider
    extends
        $FunctionalProvider<
          PaginatedContacts,
          PaginatedContacts,
          PaginatedContacts
        >
    with $Provider<PaginatedContacts> {
  PaginatedContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedContactsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedContactsHash();

  @$internal
  @override
  $ProviderElement<PaginatedContacts> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaginatedContacts create(Ref ref) {
    return paginatedContacts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedContacts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedContacts>(value),
    );
  }
}

String _$paginatedContactsHash() => r'5439d891b44660ded6db8cf6c819464dbd69aa04';

@ProviderFor(contactsTotalCount)
final contactsTotalCountProvider = ContactsTotalCountProvider._();

final class ContactsTotalCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ContactsTotalCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsTotalCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsTotalCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return contactsTotalCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$contactsTotalCountHash() =>
    r'fe73c8418df46f8e9cc141de7b8aeb9419398885';
