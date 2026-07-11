import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/data/sale_fa_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sale_fa_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sale_fa_repository.dart';
import 'package:billing_baba/features/sales/models/dto/sale_fa_dto.dart';
import 'package:billing_baba/features/sales/models/mappers/sale_fa_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_fa_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/models/requests/sale_fa_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_fa_service.g.dart';

class PaginatedSaleFa {
  const PaginatedSaleFa({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<SaleFaModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

@Riverpod(keepAlive: true)
Future<SaleFaService> saleFaService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final partyService = await ref.watch(partyServiceProvider.future);
  return SaleFaService(
    repository: SaleFaRepository(
      remote: SaleFaRemoteDataSource(api.dio),
      local: const SaleFaLocalDataSource(),
    ),
    partyService: partyService,
  );
}

class SaleFaService {
  SaleFaService({
    required this._repository,
    required this._partyService,
  });

  final SaleFaRepository _repository;
  final PartyService _partyService;

  Future<Map<String, String>> _partyNameMap() async {
    final parties = await _partyService.fetchParties();
    return {for (final party in parties) party.id: party.name};
  }

  Future<PaginatedSaleFa> fetchBatchesPage(SaleFaListQuery query) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listBatches(query);
      final items = response.batches
          .map(
            (dto) => SaleFaMapper.toModel(
              dto,
              partyName: partyNames[dto.partyId] ?? dto.partyName,
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0 ? 1 : (total / query.limit).ceil();

      return PaginatedSaleFa(
        items: items,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<AddSaleFaFormState> loadForm(String batchId) async {
    try {
      final batch = await _repository.getBatch(batchId);
      return SaleFaMapper.toFormState(batch);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SaleFaModel> createBatch(AddSaleFaFormState form) async {
    try {
      if (form.partyId == null || form.partyId!.isEmpty) {
        throw const SalesException('Customer is required');
      }

      final batch = await _repository.createBatch(
        SaleFaMapper.toCreateRequest(form),
      );
      final partyNames = await _partyNameMap();
      return SaleFaMapper.toModel(
        SaleFaBatchListDto(
          id: batch.id,
          partyId: batch.partyId,
          partyName: batch.partyName,
          referenceNumber: batch.referenceNumber,
          saleDate: batch.saleDate,
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
      throw mapSalesError(error);
    }
  }

  Future<SaleFaModel> updateBatch(
    String batchId,
    AddSaleFaFormState form,
  ) async {
    try {
      final batch = await _repository.updateBatch(
        batchId,
        SaleFaMapper.toUpdateRequest(form),
      );
      final partyNames = await _partyNameMap();
      return SaleFaMapper.toModel(
        SaleFaBatchListDto(
          id: batch.id,
          partyId: batch.partyId,
          partyName: batch.partyName,
          referenceNumber: batch.referenceNumber,
          saleDate: batch.saleDate,
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
      throw mapSalesError(error);
    }
  }

  Future<void> deleteBatch(String batchId) async {
    try {
      await _repository.deleteBatch(batchId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }
}
