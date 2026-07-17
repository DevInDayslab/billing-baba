import 'dart:async';

import 'package:billing_baba/features/search/application/recent_search_storage.dart';
import 'package:billing_baba/features/search/application/search_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Records shell navigation into recent search pages.
void recordSearchRouteVisit(WidgetRef ref, String path) {
  final item = SearchRegistry.pageForRoute(path);
  if (item == null || !item.trackAsRecentPage) return;

  unawaited(ref.read(recentSearchStorageProvider).recordPageVisit(item.id));
}
