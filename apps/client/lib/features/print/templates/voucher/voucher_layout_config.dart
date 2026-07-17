import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';

/// Layout configuration for voucher PDF output.
class VoucherLayoutConfig {
  const VoucherLayoutConfig({
    required this.title,
    required this.voucherNumberLabel,
    required this.partyHeading,
    required this.showAllocationTable,
    required this.showAssetTable,
    required this.showJobWorkMaterials,
    required this.showJobWorkCharges,
    required this.showAmountInWords,
    required this.showSignature,
  });

  final String title;
  final String voucherNumberLabel;
  final String partyHeading;
  final bool showAllocationTable;
  final bool showAssetTable;
  final bool showJobWorkMaterials;
  final bool showJobWorkCharges;
  final bool showAmountInWords;
  final bool showSignature;

  static VoucherLayoutConfig forDocument(PrintableDocument document) {
    return switch (document.kind) {
      PrintableDocumentKind.paymentIn => const VoucherLayoutConfig(
        title: 'PAYMENT RECEIPT',
        voucherNumberLabel: 'Receipt No',
        partyHeading: 'Received From',
        showAllocationTable: true,
        showAssetTable: false,
        showJobWorkMaterials: false,
        showJobWorkCharges: false,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.paymentOut => const VoucherLayoutConfig(
        title: 'PAYMENT VOUCHER',
        voucherNumberLabel: 'Voucher No',
        partyHeading: 'Paid To',
        showAllocationTable: true,
        showAssetTable: false,
        showJobWorkMaterials: false,
        showJobWorkCharges: false,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.expense => const VoucherLayoutConfig(
        title: 'EXPENSE VOUCHER',
        voucherNumberLabel: 'Voucher No',
        partyHeading: 'Party',
        showAllocationTable: false,
        showAssetTable: false,
        showJobWorkMaterials: false,
        showJobWorkCharges: false,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.fixedAssetPurchase => const VoucherLayoutConfig(
        title: 'FIXED ASSET PURCHASE VOUCHER',
        voucherNumberLabel: 'Voucher No',
        partyHeading: 'Supplier',
        showAllocationTable: false,
        showAssetTable: true,
        showJobWorkMaterials: false,
        showJobWorkCharges: false,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.saleFa => const VoucherLayoutConfig(
        title: 'SALE FA VOUCHER',
        voucherNumberLabel: 'Invoice No',
        partyHeading: 'Customer',
        showAllocationTable: false,
        showAssetTable: true,
        showJobWorkMaterials: false,
        showJobWorkCharges: false,
        showAmountInWords: true,
        showSignature: true,
      ),
      PrintableDocumentKind.jobWorkOrder => const VoucherLayoutConfig(
        title: 'JOB WORK ORDER',
        voucherNumberLabel: 'Job No',
        partyHeading: 'Customer',
        showAllocationTable: false,
        showAssetTable: false,
        showJobWorkMaterials: true,
        showJobWorkCharges: true,
        showAmountInWords: true,
        showSignature: true,
      ),
      _ => throw StateError('Not a voucher document: ${document.kind}'),
    };
  }
}
