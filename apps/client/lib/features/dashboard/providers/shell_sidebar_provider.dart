import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shell_sidebar_provider.g.dart';

/// Sidebar entries hidden from navigation chrome.
abstract final class ShellSidebarVisibility {
  static const hidePos = false;
  static const hideSettings = false;
  static const hideUtilities = false;
  static const hideCollaboration = false;
  static const hideDeveloper = false;

  static const hiddenSaleSubRoutes = <String>{};
}

/// Shell sidebar open/collapse state, persisted across sessions.
@Riverpod(keepAlive: true)
class ShellSidebar extends _$ShellSidebar {
  @override
  ShellSidebarState build() {
    _loadCollapsedPreference();
    return const ShellSidebarState();
  }

  Future<void> _loadCollapsedPreference() async {
    final storage = await ref.read(storageServiceProvider.future);
    final value = storage.read(StorageKeys.sidebarCollapsed);
    if (value == 'true') {
      state = state.copyWith(isCollapsed: true);
    }
  }

  Future<void> _persistCollapsed(bool collapsed) async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.write(StorageKeys.sidebarCollapsed, collapsed.toString());
  }

  void setCollapsed(bool collapsed) {
    state = state.copyWith(isCollapsed: collapsed);
    _persistCollapsed(collapsed);
  }

  void toggleCollapsed() => setCollapsed(!state.isCollapsed);

  void expand() => setCollapsed(false);

  void openDrawer() => state = state.copyWith(isDrawerOpen: true);

  void closeDrawer() => state = state.copyWith(isDrawerOpen: false);

  /// Dismisses sidebar chrome after the user picks a destination.
  ///
  /// Overlay layouts close the slide-out drawer; persistent desktop layouts
  /// collapse back to the icon rail.
  void closeOnNavigation({required bool overlayLayout}) {
    if (overlayLayout) {
      state = state.copyWith(isDrawerOpen: false);
      return;
    }
    setCollapsed(true);
  }
}

class ShellSidebarState {
  const ShellSidebarState({
    this.isCollapsed = false,
    this.isDrawerOpen = false,
  });

  final bool isCollapsed;
  final bool isDrawerOpen;

  ShellSidebarState copyWith({bool? isCollapsed, bool? isDrawerOpen}) {
    return ShellSidebarState(
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
    );
  }
}
