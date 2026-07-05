import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/models/printable_assets.dart';
import 'package:billing_baba/features/print/models/printable_company.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/models/printable_line_item.dart';
import 'package:billing_baba/features/print/models/printable_metadata.dart';
import 'package:billing_baba/features/print/models/printable_party.dart';
import 'package:billing_baba/features/print/models/printable_tax_summary.dart';
import 'package:billing_baba/features/print/models/printable_totals.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
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
    this.salesDocument,
    this.purchaseDocument,
    this.payment,
  });

  final PrintableDocumentKind kind;
  final PrintRequest request;
  final PrintableCompany company;
  final PrintableParty? party;
  final List<PrintableLineItem> lines;
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

  bool get hasLineItems => lines.isNotEmpty;
}
