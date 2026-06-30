import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_list_provider.g.dart';

@riverpod
class BusinessListNotifier extends _$BusinessListNotifier {
  @override
  List<BusinessModel> build() {
    return [
      BusinessModel(
        id: '1',
        name: 'DD STOCK',
        isCurrent: true,
        syncStatus: SyncStatus.on,
        lastSaleAt: DateTime(2025, 9, 14, 14, 30),
      ),
      BusinessModel(
        id: '2',
        name: '7987016325',
        syncStatus: SyncStatus.on,
        lastSaleAt: DateTime(2026, 6, 29, 10, 15),
      ),
    ];
  }

  void selectBusiness(String id) {
    // Temporary: will be replaced with navigation/state update.
    // ignore: avoid_print
    print('Selected business id: $id');
  }
}
