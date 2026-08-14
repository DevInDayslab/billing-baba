import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/repositories/party_reminder_schedule_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_reminder_schedule_provider.g.dart';

@Riverpod(keepAlive: true)
Future<PartyReminderScheduleRepository> partyReminderScheduleRepository(
  Ref ref,
) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  return PartyReminderScheduleRepository(storage, businessId);
}

@Riverpod(keepAlive: true)
class PartyReminderScheduleMap extends _$PartyReminderScheduleMap {
  @override
  Future<Map<String, PartyReminderSchedule>> build() async {
    ref.watch(currentBusinessProvider);
    final repo = await ref.watch(
      partyReminderScheduleRepositoryProvider.future,
    );
    return repo.loadAll();
  }

  Future<void> save(PartyReminderSchedule schedule) async {
    final repo = await ref.read(partyReminderScheduleRepositoryProvider.future);
    await repo.save(schedule);
    final current = state.asData?.value ?? {};
    state = AsyncData({...current, schedule.partyId: schedule});
  }

  Future<void> clear(String partyId) async {
    final repo = await ref.read(partyReminderScheduleRepositoryProvider.future);
    await repo.clear(partyId);
    final current = Map<String, PartyReminderSchedule>.from(
      state.asData?.value ?? {},
    );
    current.remove(partyId);
    state = AsyncData(current);
  }
}

@riverpod
PartyReminderSchedule? partyNextReminder(Ref ref, String partyId) {
  final map = ref.watch(partyReminderScheduleMapProvider).asData?.value;
  return map?[partyId];
}
