// Riverpod notifiers intentionally expose imperative update methods.
// ignore_for_file: use_setters_to_change_properties

import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/repositories/business_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BusinessTab { myBusinesses, sharedWithMe }

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepository(),
);

final businessSearchProvider = NotifierProvider<BusinessSearchNotifier, String>(
  BusinessSearchNotifier.new,
);

final businessTabProvider = NotifierProvider<BusinessTabNotifier, BusinessTab>(
  BusinessTabNotifier.new,
);

final selectedBusinessProvider =
    NotifierProvider<SelectedBusinessNotifier, BusinessModel?>(
      SelectedBusinessNotifier.new,
    );

final businessListProvider =
    AsyncNotifierProvider<BusinessListNotifier, List<BusinessModel>>(
      BusinessListNotifier.new,
    );

class BusinessSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String value) => state = value;

  void clearQuery() => state = '';
}

class BusinessTabNotifier extends Notifier<BusinessTab> {
  @override
  BusinessTab build() => BusinessTab.myBusinesses;

  void selectTab(BusinessTab value) => state = value;
}

class SelectedBusinessNotifier extends Notifier<BusinessModel?> {
  @override
  BusinessModel? build() => null;

  void select(BusinessModel? value) => state = value;

  void clear() => state = null;
}

class BusinessListNotifier extends AsyncNotifier<List<BusinessModel>> {
  @override
  Future<List<BusinessModel>> build() => _fetchBusinesses();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchBusinesses);
  }

  Future<List<BusinessModel>> _fetchBusinesses() async {
    final query = ref.watch(businessSearchProvider);
    final tab = ref.watch(businessTabProvider);
    final repository = ref.watch(businessRepositoryProvider);

    final businesses = query.isEmpty
        ? await repository.getBusinesses()
        : await repository.searchBusinesses(query);

    return businesses
        .where(
          (business) => tab == BusinessTab.myBusinesses
              ? !business.isShared
              : business.isShared,
        )
        .toList();
  }
}
