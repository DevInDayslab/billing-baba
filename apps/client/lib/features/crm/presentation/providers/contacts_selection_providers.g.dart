// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedContactId)
final selectedContactIdProvider = SelectedContactIdProvider._();

final class SelectedContactIdProvider
    extends $NotifierProvider<SelectedContactId, String?> {
  SelectedContactIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedContactIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedContactIdHash();

  @$internal
  @override
  SelectedContactId create() => SelectedContactId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedContactIdHash() => r'3a6d814636d42b2e44c3bfc5d218ab0555a803fe';

abstract class _$SelectedContactId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedContactIds)
final selectedContactIdsProvider = SelectedContactIdsProvider._();

final class SelectedContactIdsProvider
    extends $NotifierProvider<SelectedContactIds, Set<String>> {
  SelectedContactIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedContactIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedContactIdsHash();

  @$internal
  @override
  SelectedContactIds create() => SelectedContactIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectedContactIdsHash() =>
    r'3498803827dca6870609efcf7f50688b0cdb65fa';

abstract class _$SelectedContactIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ContactSearchQuery)
final contactSearchQueryProvider = ContactSearchQueryProvider._();

final class ContactSearchQueryProvider
    extends $NotifierProvider<ContactSearchQuery, String> {
  ContactSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactSearchQueryHash();

  @$internal
  @override
  ContactSearchQuery create() => ContactSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$contactSearchQueryHash() =>
    r'f8f1e675e3beb091d21d05e3dab8027bd9af8974';

abstract class _$ContactSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ContactFilters)
final contactFiltersProvider = ContactFiltersProvider._();

final class ContactFiltersProvider
    extends $NotifierProvider<ContactFilters, ContactFiltersState> {
  ContactFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactFiltersHash();

  @$internal
  @override
  ContactFilters create() => ContactFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactFiltersState>(value),
    );
  }
}

String _$contactFiltersHash() => r'56f2cd7605db461f3284aa6805197d20167eaffd';

abstract class _$ContactFilters extends $Notifier<ContactFiltersState> {
  ContactFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ContactFiltersState, ContactFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactFiltersState, ContactFiltersState>,
              ContactFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
