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
        throw const PurchaseException('Supplier is required');
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
}
