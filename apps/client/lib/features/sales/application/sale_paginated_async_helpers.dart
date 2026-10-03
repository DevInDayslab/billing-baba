import 'package:billing_baba/features/sales/application/job_work_service.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _emptyPaginatedSaleInvoices = PaginatedSaleInvoices(
  items: [],
  currentPage: 1,
  totalPages: 1,
  totalItems: 0,
);

/// Keeps the last loaded rows visible while a list provider reloads.
List<SaleInvoiceModel> saleInvoiceItemsFromPaginatedAsync(
  AsyncValue<PaginatedSaleInvoices> async,
) {
  final previousItems = async.value?.items;
  return async.when(
    data: (page) => page.items,
    loading: () => previousItems ?? const [],
    error: (_, _) => previousItems ?? const [],
  );
}

/// Preserves the previous page metadata during silent reloads.
PaginatedSaleInvoices paginatedSaleInvoicesFromAsync(
  AsyncValue<PaginatedSaleInvoices> async,
) {
  return async.when(
    data: (page) => page,
    loading: () => async.value ?? _emptyPaginatedSaleInvoices,
    error: (_, _) => async.value ?? _emptyPaginatedSaleInvoices,
  );
}

List<JobWorkOrderListItem> jobWorkOrderItemsFromAsync(
  AsyncValue<PaginatedJobWorkOrders> async,
) {
  final previousItems = async.value?.items;
  return async.when(
    data: (page) => page.items,
    loading: () => previousItems ?? const [],
    error: (_, _) => previousItems ?? const [],
  );
}
