import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_fa_dto.dart';
import 'package:billing_baba/features/purchases/models/mappers/purchase_fa_mapper.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_fa_service.g.dart';

class PaginatedPurchaseFa {
  const PaginatedPurchaseFa({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseFaModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

@Riverpod(keepAlive: true)
Future<PurchaseFaService> purchaseFaService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final partyService = await ref.watch(partyServiceProvider.future);
  return PurchaseFaService(
    repository: PurchaseFaRepository(
      remote: PurchaseFaRemoteDataSource(api.dio),
      local: const PurchaseFaLocalDataSource(),
    ),
    partyService: partyService,
  );
}

class PurchaseFaService {
  PurchaseFaService({
    required this._repository,
    required this._partyService,
  });

  final PurchaseFaRepository _repository;
  final PartyService _partyService;

  Future<Map<String, String>> _partyNameMap() async {
    final parties = await _partyService.fetchParties();
    return {for (final party in parties) party.id: party.name};
  }

  Future<PaginatedPurchaseFa> fetchBatchesPage(
    PurchaseFaListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listBatches(query);
      final items = response.batches
          .map(
            (dto) => PurchaseFaMapper.toModel(
              dto,
              partyName: partyNames[dto.partyId] ?? dto.partyName,
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0 ? 1 : (total / query.limit).ceil();

      return PaginatedPurchaseFa(
        items: items,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<AddPurchaseFaFormState> loadForm(String batchId) async {
    try {
      final batch = await _repository.getBatch(batchId);
      return PurchaseFaMapper.toFormState(batch);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseFaModel> createBatch(AddPurchaseFaFormState form) async {
    try {
      if (form.partyId == null || form.partyId!.isEmpty) {
        throw const PurchaseException('Party is required');
      }

      final batch = await _repository.createBatch(
        PurchaseFaMapper.toCreateRequest(form),
      );
      final partyNames = await _partyNameMap();
      return PurchaseFaMapper.toModel(
        PurchaseFaBatchListDto(
          id: batch.id,
          partyId: batch.partyId,
          partyName: batch.partyName,
          referenceNumber: batch.referenceNumber,
          purchaseDate: batch.purchaseDate,
          dueDate: batch.dueDate,
          paymentMode: batch.paymentMode,
          totalAmount: batch.totalAmount,
          balanceDue: batch.balanceDue,
          status: batch.status,
          createdAt: batch.createdAt,
          updatedAt: batch.updatedAt,
        ),
        partyName: partyNames[batch.partyId] ?? batch.partyName,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseFaModel> updateBatch(
    String batchId,
    AddPurchaseFaFormState form,
  ) async {
    try {
      final batch = await _repository.updateBatch(
        batchId,
        PurchaseFaMapper.toUpdateRequest(form),
      );
      final partyNames = await _partyNameMap();
      return PurchaseFaMapper.toModel(
        PurchaseFaBatchListDto(
          id: batch.id,
          partyId: batch.partyId,
          partyName: batch.partyName,
          referenceNumber: batch.referenceNumber,
          purchaseDate: batch.purchaseDate,
          dueDate: batch.dueDate,
          paymentMode: batch.paymentMode,
          totalAmount: batch.totalAmount,
          balanceDue: batch.balanceDue,
          status: batch.status,
          createdAt: batch.createdAt,
          updatedAt: batch.updatedAt,
        ),
        partyName: partyNames[batch.partyId] ?? batch.partyName,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<void> deleteBatch(String batchId) async {
    try {
      await _repository.deleteBatch(batchId);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<String> duplicateBatch(String batchId) async {
    try {
      final loaded = await loadForm(batchId);
      final duplicateItems = loaded.items
          .map(
            (item) => FixedAssetLineItem(
              id: 'dup_${DateTime.now().microsecondsSinceEpoch}_${item.id}',
              assetName: item.assetName,
              description: item.description,
              qty: item.qty,
              pricePerUnit: item.pricePerUnit,
              priceIsTaxInclusive: item.priceIsTaxInclusive,
              taxPercent: item.taxPercent,
            ),
          )
          .toList();

      final duplicate = AddPurchaseFaFormState(
        partyId: loaded.partyId,
        party: loaded.party,
        billingName: loaded.billingName,
        eWayBillNo: loaded.eWayBillNo,
        billNumber: loaded.billNumber.trim().isEmpty
            ? 'Auto'
            : '${loaded.billNumber} (Copy)',
        billDate: loaded.billDate,
        billTime: loaded.billTime,
        paymentTerms: loaded.paymentTerms,
        dueDate: loaded.dueDate,
        stateOfSupply: loaded.stateOfSupply,
        termsTitle: loaded.termsTitle,
        termsNotes: loaded.termsNotes,
        items: duplicateItems,
        payments: loaded.payments,
        description: loaded.description,
        roundOff: loaded.roundOff,
      );

      final created = await createBatch(duplicate);
      return created.batchId;
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<PurchaseFaHistoryEvent>> fetchBatchHistory(String batchId) async {
    try {
      final batch = await _repository.getBatch(batchId);
      final events = <PurchaseFaHistoryEvent>[
        PurchaseFaHistoryEvent(
          timestamp: DateTime.parse(batch.createdAt).toLocal(),
          title: 'Purchase FA created',
          subtitle: batch.referenceNumber ?? batch.id,
        ),
      ];

      if (batch.status == 'finalized' || batch.status == 'paid') {
        events.add(
          PurchaseFaHistoryEvent(
            timestamp: DateTime.parse(batch.updatedAt).toLocal(),
            title: 'Purchase FA finalized',
            subtitle: batch.referenceNumber,
          ),
        );
      }

      if (batch.status == 'cancelled') {
        events.add(
          PurchaseFaHistoryEvent(
            timestamp: DateTime.parse(batch.updatedAt).toLocal(),
            title: 'Purchase FA cancelled',
            subtitle: batch.referenceNumber,
          ),
        );
      }

      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }
}

class PurchaseFaHistoryEvent {
  const PurchaseFaHistoryEvent({
    required this.timestamp,
    required this.title,
    this.subtitle,
  });

  final DateTime timestamp;
  final String title;
  final String? subtitle;
}
