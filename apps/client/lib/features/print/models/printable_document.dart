import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/models/printable_allocation.dart';
import 'package:billing_baba/features/print/models/printable_assets.dart';
import 'package:billing_baba/features/print/models/printable_company.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/models/printable_line_item.dart';
import 'package:billing_baba/features/print/models/printable_metadata.dart';
import 'package:billing_baba/features/print/models/printable_party.dart';
import 'package:billing_baba/features/print/models/printable_tax_summary.dart';
import 'package:billing_baba/features/print/models/printable_totals.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_fa_dto.dart';
import 'package:billing_baba/features/sales/models/dto/job_work_order_dto.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';

/// Unified domain model for all printable document types.
class PrintableDocument {
  const PrintableDocument({
    required this.kind,
    required this.request,
    required this.company,
    required this.metadata,
    required this.totals,
    required this.taxSummary,
    required this.assets,
    this.party,
    this.lines = const [],
    this.allocations = const [],
    this.salesDocument,
    this.purchaseDocument,
    this.payment,
    this.expense,
    this.purchaseFaBatch,
    this.jobWorkOrder,
    this.jobWorkMaterialNames = const {},
  });

  final PrintableDocumentKind kind;
  final PrintRequest request;
  final PrintableCompany company;
  final PrintableParty? party;
  final List<PrintableLineItem> lines;
  final List<PrintableAllocation> allocations;
  final PrintableMetadata metadata;
  final PrintableTotals totals;
  final PrintableTaxSummary taxSummary;
  final PrintableAssets assets;

  /// Raw sales document when loaded from the sales API.
  final SalesDocumentDto? salesDocument;

  /// Raw purchase document when loaded from the purchases API.
  final PurchaseDocumentDto? purchaseDocument;

  /// Raw payment when loaded from the accounting API.
  final PaymentDto? payment;

  /// Raw expense when loaded from the purchases API.
  final ExpenseDto? expense;

  /// Raw fixed asset batch when loaded from the purchases API.
  final PurchaseFaBatchDto? purchaseFaBatch;

  /// Raw job work order when loaded from the job work API.
  final JobWorkOrderDto? jobWorkOrder;

  /// Item id → display name for job work raw materials.
  final Map<String, String> jobWorkMaterialNames;

  bool get hasLineItems => lines.isNotEmpty;
}
