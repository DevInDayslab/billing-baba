import 'package:billing_baba/features/crm/domain/services/contact_service.dart';
import 'package:billing_baba/features/crm/domain/services/contact_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_detail_provider.g.dart';

@Riverpod(keepAlive: true)
class ContactDetail extends _$ContactDetail {
  @override
  Stream<ContactWithActivities?> build(String contactId) async* {
    final service = await ref.watch(contactServiceProvider.future);
    yield* service.watchContactDetail(contactId);
  }
}
