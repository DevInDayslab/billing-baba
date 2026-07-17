import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_search_storage.g.dart';

const _maxRecentPages = 10;
const _separator = ',';

/// Persists recently visited page IDs for the search dialog.
@Riverpod(keepAlive: true)
RecentSearchStorage recentSearchStorage(Ref ref) {
  return RecentSearchStorage(ref);
}

class RecentSearchStorage {
  RecentSearchStorage(this._ref);

  final Ref _ref;
  List<String>? _cache;

  Future<List<String>> readRecentPageIds() async {
    if (_cache != null) return List.unmodifiable(_cache!);

    final storage = await _ref.read(storageServiceProvider.future);
    final raw = storage.read(StorageKeys.recentSearchPageIds);
    if (raw == null || raw.isEmpty) {
      _cache = [];
      return [];
    }

    _cache = raw
        .split(_separator)
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    return List.unmodifiable(_cache!);
  }

  Future<void> recordPageVisit(String pageId) async {
    if (pageId.isEmpty) return;

    final current = await readRecentPageIds();
    final updated = [
      pageId,
      ...current.where((id) => id != pageId),
    ].take(_maxRecentPages).toList(growable: false);

    _cache = updated;
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.write(
      StorageKeys.recentSearchPageIds,
      updated.join(_separator),
    );
  }
}
