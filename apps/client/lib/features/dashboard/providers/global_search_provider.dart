import 'package:billing_baba/features/dashboard/application/global_search_service.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_provider.g.dart';

@riverpod
class GlobalSearchQuery extends _$GlobalSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@riverpod
Future<List<GlobalSearchResult>> globalSearchResults(Ref ref) async {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.trim().length < 2) return const [];

  final service = await ref.watch(globalSearchServiceProvider.future);
  return service.search(query);
}
