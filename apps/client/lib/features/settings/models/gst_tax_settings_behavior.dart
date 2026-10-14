import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings.dart';

/// Product behavior for persisted [GstTaxSettings] (GST settings screen).
extension GstTaxSettingsBehavior on GstTaxSettings {
  /// GST applies on sale/purchase documents (tax columns, summaries, GSTR).
  bool get enableGstTransactions => enableGst;

  /// Item-wise / bill tax fields on transactions (disabled under composite scheme).
  bool get allowsTransactionTaxes => enableGst && !compositeScheme;

  /// Formal GST document metadata (HSN, tax breakup on prints when applicable).
  bool get isGstFormalDocument => enableGst;

  bool get showPlaceOfSupplyOnTransactions =>
      enableGst && enablePlaceOfSupply;

  bool get showHsnSacOnItems => enableGst && enableHsnSac;

  bool get showAdditionalCessOnItems => enableGst && additionalCessOnItem;

  /// Master switch: reverse charge is available on purchase flows when enabled.
  bool get reverseChargeFeatureEnabled =>
      enableGst && !compositeScheme && reverseCharge;

  bool get showGstReportNav => enableGst;

  bool isGstReportSubSectionVisible(GstReportSubSection sub) => enableGst;

  bool isTaxesReportSubSectionVisible(TaxesReportSubSection sub) {
    return switch (sub) {
      TaxesReportSubSection.gstReport ||
      TaxesReportSubSection.gstRateReport =>
        enableGst,
      TaxesReportSubSection.formNo27Eq ||
      TaxesReportSubSection.tcsReceivable =>
        enableGst && enableTcs,
      TaxesReportSubSection.tdsPayable ||
      TaxesReportSubSection.tdsReceivable =>
        enableTds,
    };
  }
}
