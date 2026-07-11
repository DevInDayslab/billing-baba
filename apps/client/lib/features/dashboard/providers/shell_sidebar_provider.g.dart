// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shell_sidebar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shell sidebar open/collapse state, persisted across sessions.

@ProviderFor(ShellSidebar)
final shellSidebarProvider = ShellSidebarProvider._();

/// Shell sidebar open/collapse state, persisted across sessions.
final class ShellSidebarProvider
    extends $NotifierProvider<ShellSidebar, ShellSidebarState> {
  /// Shell sidebar open/collapse state, persisted across sessions.
  ShellSidebarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shellSidebarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shellSidebarHash();

  @$internal
  @override
  ShellSidebar create() => ShellSidebar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShellSidebarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShellSidebarState>(value),
    );
  }
}

String _$shellSidebarHash() => r'a1eea6b4d6801295fbffbeffaa046ce028e5f4bb';

/// Shell sidebar open/collapse state, persisted across sessions.

abstract class _$ShellSidebar extends $Notifier<ShellSidebarState> {
  ShellSidebarState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ShellSidebarState, ShellSidebarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShellSidebarState, ShellSidebarState>,
              ShellSidebarState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
