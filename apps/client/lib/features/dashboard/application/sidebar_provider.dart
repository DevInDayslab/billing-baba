import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/dashboard/presentation/models/sidebar_route_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sidebar_provider.g.dart';

class SidebarUiState {
  const SidebarUiState({
    this.isCollapsed = false,
    this.expandedSections = const {},
    this.isHydrated = false,
  });

  final bool isCollapsed;
  final Set<String> expandedSections;
  final bool isHydrated;

  bool isSectionExpanded(String sectionId) =>
      expandedSections.contains(sectionId);

  SidebarUiState copyWith({
    bool? isCollapsed,
    Set<String>? expandedSections,
    bool? isHydrated,
  }) {
    return SidebarUiState(
      isCollapsed: isCollapsed ?? this.isCollapsed,
      expandedSections: expandedSections ?? this.expandedSections,
      isHydrated: isHydrated ?? this.isHydrated,
    );
  }
}

@Riverpod(keepAlive: true)
class Sidebar extends _$Sidebar {
  var _hydrateStarted = false;

  @override
  SidebarUiState build() {
    if (!_hydrateStarted) {
      _hydrateStarted = true;
      Future.microtask(_hydrateFromStorage);
    }
    return const SidebarUiState();
  }

  Future<void> _hydrateFromStorage() async {
    final storage = await ref.read(storageServiceProvider.future);
    final collapsed = storage.read(StorageKeys.sidebarCollapsed) == 'true';
    final raw = storage.read(StorageKeys.sidebarExpandedSections);
    final sections = raw == null || raw.isEmpty
        ? <String>{}
        : raw.split(',').where((id) => id.isNotEmpty).toSet();

    state = state.copyWith(
      isCollapsed: collapsed,
      expandedSections: sections,
      isHydrated: true,
    );
  }

  Future<void> _persist() async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.write(
      StorageKeys.sidebarCollapsed,
      state.isCollapsed.toString(),
    );
    await storage.write(
      StorageKeys.sidebarExpandedSections,
      state.expandedSections.join(','),
    );
  }

  Future<void> toggleCollapsed() async {
    state = state.copyWith(isCollapsed: !state.isCollapsed);
    await _persist();
  }

  Future<void> setCollapsed(bool collapsed) async {
    if (state.isCollapsed == collapsed) return;
    state = state.copyWith(isCollapsed: collapsed);
    await _persist();
  }

  Future<void> toggleSection(String sectionId) async {
    final next = Set<String>.from(state.expandedSections);
    if (next.contains(sectionId)) {
      next.remove(sectionId);
    } else {
      next.add(sectionId);
    }
    state = state.copyWith(expandedSections: next);
    await _persist();
  }

  Future<void> syncExpansionForLocation(String location) async {
    final auto = SidebarRouteUtils.expandedSectionsFor(location);
    if (auto.isEmpty) return;

    final merged = Set<String>.from(state.expandedSections)..addAll(auto);
    if (merged.length == state.expandedSections.length &&
        merged.containsAll(state.expandedSections)) {
      return;
    }
    state = state.copyWith(expandedSections: merged);
    await _persist();
  }
}
