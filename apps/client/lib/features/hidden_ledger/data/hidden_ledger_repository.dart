import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';
import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_filters.dart';
import 'package:billing_baba/features/hidden_ledger/models/paginated_hidden_ledger_entries.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hidden_ledger_repository.g.dart';

@Riverpod(keepAlive: true)
Future<HiddenLedgerRepository> hiddenLedgerRepository(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return HiddenLedgerRepository(api.dio);
}

class HiddenLedgerRepository {
  HiddenLedgerRepository(this._dio);

  final Dio _dio;

  Future<PaginatedHiddenLedgerEntries> listEntries({
    HiddenLedgerFilters filters = const HiddenLedgerFilters(),
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.hiddenLedgerEntries,
      queryParameters: {
        'page': filters.page,
        'limit': filters.limit,
        if (filters.partyId != null) 'party_id': filters.partyId,
        if (filters.status != null) 'status': filters.status,
        if (filters.from != null) 'from': filters.from!.toUtc().toIso8601String(),
        if (filters.to != null) 'to': filters.to!.toUtc().toIso8601String(),
        if (filters.searchQuery.trim().isNotEmpty) 'q': filters.searchQuery.trim(),
        if (filters.invoiceNumber.trim().isNotEmpty)
          'invoice_number': filters.invoiceNumber.trim(),
      },
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];
    final meta = response.data?['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedHiddenLedgerEntries(
      entries: data
          .map(
            (item) => HiddenLedgerEntryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      page: meta['page'] as int? ?? filters.page,
      limit: meta['limit'] as int? ?? filters.limit,
      total: meta['total'] as int? ?? data.length,
    );
  }

  Future<HiddenLedgerEntryDetailModel> getEntry(String entryId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.hiddenLedgerEntry(entryId),
    );
    final data = Map<String, dynamic>.from(
      response.data?['data'] as Map? ?? {},
    );
    return HiddenLedgerEntryDetailModel.fromJson(data);
  }

  Future<HiddenLedgerPartySummaryModel> getPartySummary(String partyId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.hiddenLedgerPartySummary(partyId),
    );
    final data = Map<String, dynamic>.from(
      response.data?['data'] as Map? ?? {},
    );
    return HiddenLedgerPartySummaryModel.fromJson(data);
  }

  Future<double> recoverFromSale({
    required String partyId,
    required String saleId,
    required double amount,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.hiddenLedgerRecoverFromSale(partyId),
      data: {
        'sale_id': saleId,
        'amount': amount.toStringAsFixed(4),
      },
    );
    final data = Map<String, dynamic>.from(
      response.data?['data'] as Map? ?? {},
    );
    return double.tryParse(data['recovered_amount']?.toString() ?? '0') ?? 0;
  }
}
