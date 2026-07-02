// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Sidebar)
final sidebarProvider = SidebarProvider._();

final class SidebarProvider extends $NotifierProvider<Sidebar, SidebarUiState> {
  SidebarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarHash();

  @$internal
  @override
  Sidebar create() => Sidebar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SidebarUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SidebarUiState>(value),
    );
  }
}

String _$sidebarHash() => r'2024a11d21531211dd8336e9683ca0811aa9ae05';

abstract class _$Sidebar extends $Notifier<SidebarUiState> {
  SidebarUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SidebarUiState, SidebarUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SidebarUiState, SidebarUiState>,
              SidebarUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
