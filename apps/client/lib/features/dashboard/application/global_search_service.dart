import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/purchases/application/expense_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_service.g.dart';

@Riverpod(keepAlive: true)
Future<GlobalSearchService> globalSearchService(Ref ref) async {
  final partyService = await ref.watch(partyServiceProvider.future);
  final salesService = await ref.watch(salesServiceProvider.future);
  final purchaseService = await ref.watch(purchaseServiceProvider.future);
  final expenseService = await ref.watch(expenseServiceProvider.future);
  return GlobalSearchService(
    partyService: partyService,
    salesService: salesService,
    purchaseService: purchaseService,
    expenseService: expenseService,
  );
}

class GlobalSearchService {
  GlobalSearchService({
    required PartyService partyService,
    required SalesService salesService,
    required PurchaseService purchaseService,
    required ExpenseService expenseService,
  }) : _partyService = partyService,
       _salesService = salesService,
       _purchaseService = purchaseService,
       _expenseService = expenseService;

  final PartyService _partyService;
  final SalesService _salesService;
  final PurchaseService _purchaseService;
  final ExpenseService _expenseService;

  static const _resultLimit = 8;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<List<GlobalSearchResult>> searchAll(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final batches = await Future.wait([
      _safe(() => searchParties(trimmed)),
      _safe(() => searchSaleInvoices(trimmed)),
      _safe(() => searchPurchaseBills(trimmed)),
      _safe(() => searchExpenses(trimmed)),
      _safe(() => searchPaymentsIn(trimmed)),
      _safe(() => searchPaymentsOut(trimmed)),
    ]);

    return batches.expand((batch) => batch).toList(growable: false);
  }

  Future<List<GlobalSearchResult>> searchParties(String query) async {
    final parties = await _partyService.fetchParties(searchQuery: query);
    return parties.take(_resultLimit).map((party) {
      return GlobalSearchResult(
        type: GlobalSearchResultType.party,
        id: party.id,
        title: party.name,
        subtitle: party.phone.isNotEmpty ? party.phone : party.partyTypeLabel,
      );
    }).toList();
  }

  Future<List<GlobalSearchResult>> searchSaleInvoices(String query) async {
    final page = await _salesService.fetchInvoicesPage(
      SalesDocumentListQuery(
        page: 1,
        limit: _resultLimit,
        q: query,
        documentType: SalesDocumentType.taxInvoice.apiValue,
      ),
    );

    return page.items
        .map(
          (invoice) => GlobalSearchResult(
            type: GlobalSearchResultType.saleInvoice,
            id: invoice.id,
            title: invoice.invoiceNo,
            subtitle: _documentSubtitle(
              partyName: invoice.partyName,
              date: invoice.date,
              amount: invoice.amount,
            ),
            statusLabel: _saleInvoiceStatusLabel(invoice.status),
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> searchPurchaseBills(String query) async {
    final page = await _purchaseService.fetchBillsPage(
      PurchaseDocumentListQuery(
        page: 1,
        limit: _resultLimit,
        q: query,
      ),
    );

    return page.items
        .map(
          (bill) => GlobalSearchResult(
            type: GlobalSearchResultType.purchaseBill,
            id: bill.id,
            title: bill.invoiceNo,
            subtitle: _documentSubtitle(
              partyName: bill.partyName,
              date: bill.date,
              amount: bill.amount,
            ),
            statusLabel: _purchaseBillStatusLabel(bill.status),
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> searchExpenses(String query) async {
    final expenses = await _expenseService.fetchExpenses(
      query: const ExpenseListQuery(page: 1, limit: 100),
    );
    final normalized = query.toLowerCase();

    return expenses
        .where(
          (expense) => [
            expense.transactionNo,
            expense.party,
            expense.paymentType ?? '',
          ].any((field) => field.toLowerCase().contains(normalized)),
        )
        .take(_resultLimit)
        .map(
          (expense) => GlobalSearchResult(
            type: GlobalSearchResultType.expense,
            id: expense.id,
            title: expense.transactionNo,
            subtitle: [
              expense.party,
              if (expense.paymentType != null &&
                  expense.paymentType!.isNotEmpty)
                expense.paymentType!,
            ].join(' · '),
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> searchPaymentsIn(String query) async {
    final page = await _salesService.fetchPaymentsPage(
      const PaymentListQuery(
        page: 1,
        limit: 100,
        direction: 'received',
      ),
    );
    final normalized = query.toLowerCase();

    return page.items
        .where(
          (payment) =>
              payment.partyName.toLowerCase().contains(normalized) ||
              payment.receiptNo.toLowerCase().contains(normalized) ||
              payment.paymentType.toLowerCase().contains(normalized),
        )
        .take(_resultLimit)
        .map(
          (payment) => GlobalSearchResult(
            type: GlobalSearchResultType.payment,
            id: payment.id,
            title: payment.receiptNo,
            subtitle: [
              payment.partyName,
              payment.paymentType,
            ].join(' · '),
            route: AppRoutes.salePaymentIn,
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> searchPaymentsOut(String query) async {
    final page = await _purchaseService.fetchPaymentsPage(
      const PaymentListQuery(
        page: 1,
        limit: 100,
        direction: 'paid',
      ),
    );
    final normalized = query.toLowerCase();

    return page.items
        .where(
          (payment) =>
              payment.partyName.toLowerCase().contains(normalized) ||
              payment.receiptNo.toLowerCase().contains(normalized) ||
              payment.paymentType.toLowerCase().contains(normalized),
        )
        .take(_resultLimit)
        .map(
          (payment) => GlobalSearchResult(
            type: GlobalSearchResultType.payment,
            id: payment.id,
            title: payment.receiptNo,
            subtitle: [
              payment.partyName,
              payment.paymentType,
            ].join(' · '),
            route: AppRoutes.purchasePaymentOut,
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> _safe(
    Future<List<GlobalSearchResult>> Function() search,
  ) async {
    try {
      return await search();
    } catch (_) {
      return const [];
    }
  }

  String _documentSubtitle({
    required String partyName,
    required DateTime date,
    required double amount,
  }) {
    return [
      partyName,
      _dateFormat.format(date),
      _currencyFormat.format(amount),
    ].join(' · ');
  }

  static String _saleInvoiceStatusLabel(SaleInvoiceStatus status) =>
      switch (status) {
        SaleInvoiceStatus.paid => 'Paid',
        SaleInvoiceStatus.unpaid => 'Unpaid',
        SaleInvoiceStatus.partiallyPaid => 'Partial',
        SaleInvoiceStatus.overdue => 'Overdue',
        SaleInvoiceStatus.cancelled => 'Cancelled',
      };

  static String _purchaseBillStatusLabel(PurchaseBillStatus status) =>
      switch (status) {
        PurchaseBillStatus.paid => 'Paid',
        PurchaseBillStatus.unpaid => 'Unpaid',
        PurchaseBillStatus.partiallyPaid => 'Partial',
        PurchaseBillStatus.overdue => 'Overdue',
        PurchaseBillStatus.cancelled => 'Cancelled',
      };
}
