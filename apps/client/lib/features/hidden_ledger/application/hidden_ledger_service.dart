import 'package:billing_baba/features/hidden_ledger/data/hidden_ledger_repository.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_filters.dart';
import 'package:billing_baba/features/hidden_ledger/models/paginated_hidden_ledger_entries.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hidden_ledger_service.g.dart';

@Riverpod(keepAlive: true)
Future<HiddenLedgerService> hiddenLedgerService(Ref ref) async {
  final repository = await ref.watch(hiddenLedgerRepositoryProvider.future);
  return HiddenLedgerService(repository);
}

class HiddenLedgerService {
  HiddenLedgerService(this._repository);

  final HiddenLedgerRepository _repository;

  Future<PaginatedHiddenLedgerEntries> listEntries({
    HiddenLedgerFilters filters = const HiddenLedgerFilters(),
  }) {
    return _repository.listEntries(filters: filters);
  }

  Future<List<HiddenLedgerEntryModel>> listPartyEntries(String partyId) async {
    final result = await _repository.listEntries(
      filters: HiddenLedgerFilters(partyId: partyId, limit: 100),
    );
    return result.entries;
  }

  Future<HiddenLedgerEntryDetailModel> getEntry(String entryId) {
    return _repository.getEntry(entryId);
  }

  Future<HiddenLedgerPartySummaryModel> getPartySummary(String partyId) {
    return _repository.getPartySummary(partyId);
  }

  Future<double> recoverFromSale({
    required String partyId,
    required String saleId,
    required double amount,
  }) {
    return _repository.recoverFromSale(
      partyId: partyId,
      saleId: saleId,
      amount: amount,
    );
  }
}

@riverpod
class HiddenLedgerFiltersState extends _$HiddenLedgerFiltersState {
  @override
  HiddenLedgerFilters build() => const HiddenLedgerFilters();

  void update(HiddenLedgerFilters filters) => state = filters;

  void reset() => state = const HiddenLedgerFilters();
}

@riverpod
class HiddenLedgerList extends _$HiddenLedgerList {
  @override
  Future<PaginatedHiddenLedgerEntries> build() async {
    final filters = ref.watch(hiddenLedgerFiltersStateProvider);
    final service = await ref.watch(hiddenLedgerServiceProvider.future);
    return service.listEntries(filters: filters);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> goToPage(int page) async {
    final filters = ref.read(hiddenLedgerFiltersStateProvider);
    ref
        .read(hiddenLedgerFiltersStateProvider.notifier)
        .update(
          filters.copyWith(page: page),
        );
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<HiddenLedgerPartySummaryModel> partyHiddenLedgerSummary(
  Ref ref,
  String partyId,
) async {
  final service = await ref.watch(hiddenLedgerServiceProvider.future);
  return service.getPartySummary(partyId);
}

@riverpod
Future<List<HiddenLedgerEntryModel>> partyHiddenLedgerEntries(
  Ref ref,
  String partyId,
) async {
  final service = await ref.watch(hiddenLedgerServiceProvider.future);
  return service.listPartyEntries(partyId);
}

@riverpod
Future<HiddenLedgerEntryDetailModel> hiddenLedgerEntryDetail(
  Ref ref,
  String entryId,
) async {
  final service = await ref.watch(hiddenLedgerServiceProvider.future);
  return service.getEntry(entryId);
}
