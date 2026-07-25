import 'package:billing_baba/features/crm/domain/services/lead_service.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lead_detail_provider.g.dart';

@Riverpod(keepAlive: true)
class LeadDetail extends _$LeadDetail {
  @override
  Stream<LeadWithActivities?> build(String leadId) async* {
    final service = await ref.watch(leadServiceProvider.future);
    yield* service.watchLeadDetail(leadId);
  }
}
