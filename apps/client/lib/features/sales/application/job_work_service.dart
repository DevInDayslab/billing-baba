import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/data/job_work_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/job_work_repository.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/mappers/job_work_order_mapper.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_work_service.g.dart';

class PaginatedJobWorkOrders {
  const PaginatedJobWorkOrders({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<JobWorkOrderListItem> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

@Riverpod(keepAlive: true)
Future<JobWorkService> jobWorkService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final partyService = await ref.watch(partyServiceProvider.future);
  return JobWorkService(
    repository: JobWorkRepository(
      remote: JobWorkRemoteDataSource(api.dio),
    ),
    partyService: partyService,
  );
}

class JobWorkService {
  JobWorkService({
    required this._repository,
    required this._partyService,
  });

  final JobWorkRepository _repository;
  final PartyService _partyService;

  Future<Map<String, String>> _partyNameMap() async {
    final parties = await _partyService.fetchParties();
    return {for (final party in parties) party.id: party.name};
  }

  Future<PaginatedJobWorkOrders> fetchOrdersPage(
    JobWorkOrderListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listOrders(query);
      final items = response.orders
          .map(
            (dto) => JobWorkOrderMapper.toListItem(
              dto,
              partyName: dto.partyId != null
                  ? (partyNames[dto.partyId] ?? '')
                  : '',
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0 ? 1 : (total / query.limit).ceil();

      return PaginatedJobWorkOrders(
        items: items,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<JobWorkOutFormState> loadOrderForm(String orderId) async {
    try {
      final dto = await _repository.getOrder(orderId);
      final partyNames = await _partyNameMap();
      final partyName = dto.partyId != null
          ? (partyNames[dto.partyId] ?? '')
          : '';
      return JobWorkOrderMapper.toFormState(dto, partyName: partyName);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<JobWorkOutFormState> loadOrderFormWithItems(
    String orderId,
    Map<String, String> itemNames,
  ) async {
    try {
      final dto = await _repository.getOrder(orderId);
      final partyNames = await _partyNameMap();
      final partyName = dto.partyId != null
          ? (partyNames[dto.partyId] ?? '')
          : '';
      return JobWorkOrderMapper.toFormState(
        dto,
        partyName: partyName,
        itemNames: itemNames,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  CreateJobWorkOrderRequest _createRequest(
    JobWorkOutFormState form,
    Map<String, String> itemNameToId,
  ) {
    final rawMaterials = <JobWorkRawMaterialRequest>[];
    for (final material in form.rawMaterials) {
      if (material.itemName.trim().isEmpty && material.qty <= 0) continue;
      final itemId = material.itemId ?? itemNameToId[material.itemName.trim()];
      if (itemId == null) {
        throw SalesException('Item not found: ${material.itemName}');
      }
      rawMaterials.add(
        JobWorkRawMaterialRequest(
          itemId: itemId,
          quantity: material.qty.toStringAsFixed(4),
          unit: material.unit,
          purchasePrice: material.purchasePrice.toStringAsFixed(4),
        ),
      );
    }

    final additionalCosts = form.additionalCosts
        .where((cost) => cost.label.trim().isNotEmpty || cost.amount > 0)
        .map(
          (cost) => JobWorkAdditionalCostRequest(
            label: cost.label.trim().isEmpty ? 'Cost' : cost.label.trim(),
            amount: cost.amount.toStringAsFixed(4),
          ),
        )
        .toList();

    return CreateJobWorkOrderRequest(
      partyId: form.partyId,
      jobNumber: form.jobId.trim().isEmpty ? null : form.jobId.trim(),
      orderDate: form.invoiceDate?.toUtc().toIso8601String(),
      deliveryDate: form.deliveryDate?.toUtc().toIso8601String(),
      finishedGoodName: form.finishedGoodName.trim(),
      finishedGoodQuantity: form.finishedGoodQty.toStringAsFixed(4),
      finishedGoodUnit: form.finishedGoodUnit,
      notes: form.description.trim().isEmpty ? null : form.description.trim(),
      rawMaterials: rawMaterials,
      additionalCosts: additionalCosts,
    );
  }

  UpdateJobWorkOrderRequest _updateRequest(
    JobWorkOutFormState form,
    Map<String, String> itemNameToId,
  ) {
    final create = _createRequest(form, itemNameToId);
    return UpdateJobWorkOrderRequest(
      partyId: create.partyId,
      jobNumber: create.jobNumber,
      deliveryDate: create.deliveryDate,
      finishedGoodName: create.finishedGoodName,
      finishedGoodQuantity: create.finishedGoodQuantity,
      finishedGoodUnit: create.finishedGoodUnit,
      notes: create.notes,
      rawMaterials: create.rawMaterials,
      additionalCosts: create.additionalCosts,
    );
  }

  Future<String> saveOrder(
    JobWorkOutFormState form, {
    required Map<String, String> itemNameToId,
  }) async {
    try {
      if (form.orderId == null) {
        final created = await _repository.createOrder(
          _createRequest(form, itemNameToId),
        );
        return created.id;
      }
      await _repository.updateOrder(
        form.orderId!,
        _updateRequest(form, itemNameToId),
      );
      return form.orderId!;
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) {
        throw SalesException(
          validation.message,
          code: 'VALIDATION_ERROR',
          fieldErrors: validation.fieldErrors.map(
            (key, value) => MapEntry(key, [value]),
          ),
        );
      }
      throw mapSalesError(error);
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _repository.deleteOrder(orderId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<void> closeOrder(String orderId) async {
    try {
      await _repository.updateOrder(
        orderId,
        const UpdateJobWorkOrderRequest(status: 'closed'),
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }
}
