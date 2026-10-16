import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/desktop_ui_scale.dart';

typedef GeneralSettingsUpdater = GeneralSettings Function(GeneralSettings s);

/// Business-scoped general preferences (device-local persistence).
class GeneralSettings {
  const GeneralSettings({
    required this.enablePasscode,
    required this.appPasscode,
    required this.amountDecimalPlaces,
    required this.enableGstinOnParty,
    required this.stopSaleOnNegativeStock,
    required this.blockNewItemsFromTxnForm,
    required this.blockNewPartiesFromTxnForm,
    required this.autoBackupEnabled,
    required this.auditTrailEnabled,
    required this.enableEstimateQuotation,
    required this.enableProformaInvoice,
    required this.enableSalePurchaseOrder,
    required this.enableOtherIncome,
    required this.enableFixedAssets,
    required this.enableDeliveryChallan,
    required this.deliveryChallanGoodsReturn,
    required this.deliveryChallanPrintAmount,
    required this.multiFirmEnabled,
    required this.selectedFirmBusinessId,
    required this.godownStockTransferEnabled,
    required this.desktopUiScalePercent,
  });

  factory GeneralSettings.defaults() => const GeneralSettings(
    enablePasscode: false,
    appPasscode: '',
    amountDecimalPlaces: 0,
    enableGstinOnParty: true,
    stopSaleOnNegativeStock: true,
    blockNewItemsFromTxnForm: false,
    blockNewPartiesFromTxnForm: false,
    autoBackupEnabled: false,
    auditTrailEnabled: true,
    enableEstimateQuotation: true,
    enableProformaInvoice: true,
    enableSalePurchaseOrder: true,
    enableOtherIncome: true,
    enableFixedAssets: true,
    enableDeliveryChallan: true,
    deliveryChallanGoodsReturn: true,
    deliveryChallanPrintAmount: true,
    multiFirmEnabled: false,
    selectedFirmBusinessId: '',
    godownStockTransferEnabled: false,
    desktopUiScalePercent: 100,
  );

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    final defaults = GeneralSettings.defaults();
    return GeneralSettings(
      enablePasscode: json['enablePasscode'] as bool? ?? defaults.enablePasscode,
      appPasscode: json['appPasscode'] as String? ?? defaults.appPasscode,
      amountDecimalPlaces:
          (json['amountDecimalPlaces'] as num?)?.toInt() ??
          defaults.amountDecimalPlaces,
      enableGstinOnParty:
          json['enableGstinOnParty'] as bool? ?? defaults.enableGstinOnParty,
      stopSaleOnNegativeStock:
          json['stopSaleOnNegativeStock'] as bool? ??
          defaults.stopSaleOnNegativeStock,
      blockNewItemsFromTxnForm:
          json['blockNewItemsFromTxnForm'] as bool? ??
          defaults.blockNewItemsFromTxnForm,
      blockNewPartiesFromTxnForm:
          json['blockNewPartiesFromTxnForm'] as bool? ??
          defaults.blockNewPartiesFromTxnForm,
      autoBackupEnabled:
          json['autoBackupEnabled'] as bool? ?? defaults.autoBackupEnabled,
      auditTrailEnabled:
          json['auditTrailEnabled'] as bool? ?? defaults.auditTrailEnabled,
      enableEstimateQuotation:
          json['enableEstimateQuotation'] as bool? ??
          defaults.enableEstimateQuotation,
      enableProformaInvoice:
          json['enableProformaInvoice'] as bool? ??
          defaults.enableProformaInvoice,
      enableSalePurchaseOrder:
          json['enableSalePurchaseOrder'] as bool? ??
          defaults.enableSalePurchaseOrder,
      enableOtherIncome:
          json['enableOtherIncome'] as bool? ?? defaults.enableOtherIncome,
      enableFixedAssets:
          json['enableFixedAssets'] as bool? ?? defaults.enableFixedAssets,
      enableDeliveryChallan:
          json['enableDeliveryChallan'] as bool? ??
          defaults.enableDeliveryChallan,
      deliveryChallanGoodsReturn:
          json['deliveryChallanGoodsReturn'] as bool? ??
          defaults.deliveryChallanGoodsReturn,
      deliveryChallanPrintAmount:
          json['deliveryChallanPrintAmount'] as bool? ??
          defaults.deliveryChallanPrintAmount,
      multiFirmEnabled:
          json['multiFirmEnabled'] as bool? ?? defaults.multiFirmEnabled,
      selectedFirmBusinessId:
          json['selectedFirmBusinessId'] as String? ??
          defaults.selectedFirmBusinessId,
      godownStockTransferEnabled:
          json['godownStockTransferEnabled'] as bool? ??
          defaults.godownStockTransferEnabled,
      desktopUiScalePercent: DesktopUiScale.normalizePercent(
        (json['desktopUiScalePercent'] as num?)?.toInt() ??
            defaults.desktopUiScalePercent,
      ),
    );
  }

  final bool enablePasscode;
  final String appPasscode;
  final int amountDecimalPlaces;
  final bool enableGstinOnParty;
  final bool stopSaleOnNegativeStock;
  final bool blockNewItemsFromTxnForm;
  final bool blockNewPartiesFromTxnForm;
  final bool autoBackupEnabled;
  final bool auditTrailEnabled;
  final bool enableEstimateQuotation;
  final bool enableProformaInvoice;
  final bool enableSalePurchaseOrder;
  final bool enableOtherIncome;
  final bool enableFixedAssets;
  final bool enableDeliveryChallan;
  final bool deliveryChallanGoodsReturn;
  final bool deliveryChallanPrintAmount;
  final bool multiFirmEnabled;
  final String selectedFirmBusinessId;
  final bool godownStockTransferEnabled;
  final int desktopUiScalePercent;

  Map<String, dynamic> toJson() => {
    'enablePasscode': enablePasscode,
    'appPasscode': appPasscode,
    'amountDecimalPlaces': amountDecimalPlaces,
    'enableGstinOnParty': enableGstinOnParty,
    'stopSaleOnNegativeStock': stopSaleOnNegativeStock,
    'blockNewItemsFromTxnForm': blockNewItemsFromTxnForm,
    'blockNewPartiesFromTxnForm': blockNewPartiesFromTxnForm,
    'autoBackupEnabled': autoBackupEnabled,
    'auditTrailEnabled': auditTrailEnabled,
    'enableEstimateQuotation': enableEstimateQuotation,
    'enableProformaInvoice': enableProformaInvoice,
    'enableSalePurchaseOrder': enableSalePurchaseOrder,
    'enableOtherIncome': enableOtherIncome,
    'enableFixedAssets': enableFixedAssets,
    'enableDeliveryChallan': enableDeliveryChallan,
    'deliveryChallanGoodsReturn': deliveryChallanGoodsReturn,
    'deliveryChallanPrintAmount': deliveryChallanPrintAmount,
    'multiFirmEnabled': multiFirmEnabled,
    'selectedFirmBusinessId': selectedFirmBusinessId,
    'godownStockTransferEnabled': godownStockTransferEnabled,
    'desktopUiScalePercent': desktopUiScalePercent,
  };

  GeneralSettings copyWith({
    bool? enablePasscode,
    String? appPasscode,
    int? amountDecimalPlaces,
    bool? enableGstinOnParty,
    bool? stopSaleOnNegativeStock,
    bool? blockNewItemsFromTxnForm,
    bool? blockNewPartiesFromTxnForm,
    bool? autoBackupEnabled,
    bool? auditTrailEnabled,
    bool? enableEstimateQuotation,
    bool? enableProformaInvoice,
    bool? enableSalePurchaseOrder,
    bool? enableOtherIncome,
    bool? enableFixedAssets,
    bool? enableDeliveryChallan,
    bool? deliveryChallanGoodsReturn,
    bool? deliveryChallanPrintAmount,
    bool? multiFirmEnabled,
    String? selectedFirmBusinessId,
    bool? godownStockTransferEnabled,
    int? desktopUiScalePercent,
  }) {
    return GeneralSettings(
      enablePasscode: enablePasscode ?? this.enablePasscode,
      appPasscode: appPasscode ?? this.appPasscode,
      amountDecimalPlaces: amountDecimalPlaces ?? this.amountDecimalPlaces,
      enableGstinOnParty: enableGstinOnParty ?? this.enableGstinOnParty,
      stopSaleOnNegativeStock:
          stopSaleOnNegativeStock ?? this.stopSaleOnNegativeStock,
      blockNewItemsFromTxnForm:
          blockNewItemsFromTxnForm ?? this.blockNewItemsFromTxnForm,
      blockNewPartiesFromTxnForm:
          blockNewPartiesFromTxnForm ?? this.blockNewPartiesFromTxnForm,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      auditTrailEnabled: auditTrailEnabled ?? this.auditTrailEnabled,
      enableEstimateQuotation:
          enableEstimateQuotation ?? this.enableEstimateQuotation,
      enableProformaInvoice:
          enableProformaInvoice ?? this.enableProformaInvoice,
      enableSalePurchaseOrder:
          enableSalePurchaseOrder ?? this.enableSalePurchaseOrder,
      enableOtherIncome: enableOtherIncome ?? this.enableOtherIncome,
      enableFixedAssets: enableFixedAssets ?? this.enableFixedAssets,
      enableDeliveryChallan:
          enableDeliveryChallan ?? this.enableDeliveryChallan,
      deliveryChallanGoodsReturn:
          deliveryChallanGoodsReturn ?? this.deliveryChallanGoodsReturn,
      deliveryChallanPrintAmount:
          deliveryChallanPrintAmount ?? this.deliveryChallanPrintAmount,
      multiFirmEnabled: multiFirmEnabled ?? this.multiFirmEnabled,
      selectedFirmBusinessId:
          selectedFirmBusinessId ?? this.selectedFirmBusinessId,
      godownStockTransferEnabled:
          godownStockTransferEnabled ?? this.godownStockTransferEnabled,
      desktopUiScalePercent:
          desktopUiScalePercent ?? this.desktopUiScalePercent,
    );
  }

  /// Sidebar / navigation visibility for transaction list routes.
  bool isNavRouteVisible(String route) {
    return switch (route) {
      AppRoutes.saleEstimateQuotation => enableEstimateQuotation,
      AppRoutes.saleProformaInvoice => enableProformaInvoice,
      AppRoutes.saleOrder => enableSalePurchaseOrder,
      AppRoutes.purchaseOrder => enableSalePurchaseOrder,
      AppRoutes.saleDeliveryChallan => enableDeliveryChallan,
      AppRoutes.saleFa => enableFixedAssets,
      AppRoutes.purchaseFa => enableFixedAssets,
      AppRoutes.otherIncome => enableOtherIncome,
      _ => true,
    };
  }

  /// Maps add/edit document paths to their list route for [isNavRouteVisible].
  static String? listRouteForTransactionPath(String path) {
    if (path == AppRoutes.addEstimate ||
        path.startsWith('${AppRoutes.editEstimate}/') ||
        path.startsWith('${AppRoutes.duplicateEstimate}/')) {
      return AppRoutes.saleEstimateQuotation;
    }
    if (path == AppRoutes.addProforma ||
        path.startsWith('${AppRoutes.editProforma}/')) {
      return AppRoutes.saleProformaInvoice;
    }
    if (path == AppRoutes.addSaleOrder ||
        path.startsWith('${AppRoutes.editSaleOrder}/')) {
      return AppRoutes.saleOrder;
    }
    if (path == AppRoutes.addDeliveryChallan ||
        path.startsWith('${AppRoutes.editDeliveryChallan}/')) {
      return AppRoutes.saleDeliveryChallan;
    }
    if (path == AppRoutes.addSaleFa ||
        path.startsWith('${AppRoutes.editSaleFa}/')) {
      return AppRoutes.saleFa;
    }
    if (path == AppRoutes.addExpense) {
      return AppRoutes.purchaseExpenses;
    }
    if (path == AppRoutes.addPurchaseOrder) {
      return AppRoutes.purchaseOrder;
    }
    if (path == AppRoutes.addPurchaseFa) {
      return AppRoutes.purchaseFa;
    }
    return switch (path) {
      AppRoutes.saleEstimateQuotation => AppRoutes.saleEstimateQuotation,
      AppRoutes.saleProformaInvoice => AppRoutes.saleProformaInvoice,
      AppRoutes.saleOrder => AppRoutes.saleOrder,
      AppRoutes.purchaseOrder => AppRoutes.purchaseOrder,
      AppRoutes.saleDeliveryChallan => AppRoutes.saleDeliveryChallan,
      AppRoutes.saleFa => AppRoutes.saleFa,
      AppRoutes.purchaseFa => AppRoutes.purchaseFa,
      AppRoutes.purchaseExpenses => AppRoutes.purchaseExpenses,
      _ => null,
    };
  }

  /// Whether [path] is allowed (list pages and their add/edit flows).
  bool isTransactionPathEnabled(String path) {
    final listRoute = listRouteForTransactionPath(path);
    if (listRoute == null) return true;
    return isNavRouteVisible(listRoute);
  }

  bool get deliveryChallanPrintAmountEnabled =>
      enableDeliveryChallan && deliveryChallanPrintAmount;

  bool get deliveryChallanGoodsReturnEnabled =>
      enableDeliveryChallan && deliveryChallanGoodsReturn;
}
