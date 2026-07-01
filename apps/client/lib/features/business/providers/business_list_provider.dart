import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_list_provider.g.dart';

@riverpod
class BusinessListNotifier extends _$BusinessListNotifier {
  @override
  List<BusinessModel> build() {
    final session = ref.watch(authProvider).session;
    if (session == null) return [];

    return session.businesses
        .map(
          (business) => BusinessModel(
            id: business.id,
            name: business.name,
            syncStatus: SyncStatus.on,
          ),
        )
        .toList();
  }

  Future<void> selectBusiness(String id) async {
    await ref.read(authProvider.notifier).selectBusiness(id);
  }
}

@riverpod
String loggedInPhone(Ref ref) {
  final auth = ref.watch(authProvider);
  final phone = auth.session?.user.phone ?? auth.phone;
  if (phone.length <= 10) return phone;
  return phone.substring(phone.length - 10);
}
