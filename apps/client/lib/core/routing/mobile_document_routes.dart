import 'package:billing_baba/core/routing/app_routes.dart';

/// Mobile transaction form routes that should render edge-to-edge without bottom nav.
abstract final class MobileDocumentRoutes {
  static const _exactPaths = <String>{
    AppRoutes.addSale,
    AppRoutes.addEstimate,
    AppRoutes.addProforma,
    AppRoutes.addPaymentIn,
    AppRoutes.addSaleOrder,
    AppRoutes.addDeliveryChallan,
    AppRoutes.addJobWork,
    AppRoutes.addSaleFa,
    AppRoutes.addCreditNote,
    AppRoutes.saleInvoiceMoreSettings,
    AppRoutes.addPurchase,
    AppRoutes.addPaymentOut,
    AppRoutes.addExpense,
    AppRoutes.addPurchaseOrder,
    AppRoutes.addDebitNote,
    AppRoutes.addPurchaseFa,
  };

  static const _pathPrefixes = <String>[
    AppRoutes.editSale,
    AppRoutes.viewSale,
    AppRoutes.duplicateSale,
    AppRoutes.editEstimate,
    AppRoutes.duplicateEstimate,
    AppRoutes.editProforma,
    AppRoutes.editSaleOrder,
    AppRoutes.editDeliveryChallan,
    AppRoutes.editJobWork,
    AppRoutes.editSaleFa,
    AppRoutes.editCreditNote,
    AppRoutes.editPurchase,
    AppRoutes.editExpense,
    AppRoutes.editPurchaseOrder,
    AppRoutes.editDebitNote,
    AppRoutes.editPurchaseFa,
  ];

  static bool hidesBottomNavigation(String location) {
    if (_exactPaths.contains(location)) return true;
    for (final prefix in _pathPrefixes) {
      if (location == prefix || location.startsWith('$prefix/')) {
        return true;
      }
    }
    return false;
  }

  static String addPaymentIn({
    String? paymentId,
    String? partyId,
    String? partyName,
  }) =>
      _withQuery(
        AppRoutes.addPaymentIn,
        paymentId: paymentId,
        partyId: partyId,
        partyName: partyName,
      );

  static String addPaymentOut({
    String? paymentId,
    String? partyId,
    String? partyName,
  }) =>
      _withQuery(
        AppRoutes.addPaymentOut,
        paymentId: paymentId,
        partyId: partyId,
        partyName: partyName,
      );

  static String _withQuery(
    String path, {
    String? paymentId,
    String? partyId,
    String? partyName,
  }) {
    final params = <String, String>{};
    if (paymentId != null && paymentId.isNotEmpty) {
      params['paymentId'] = paymentId;
    }
    if (partyId != null && partyId.isNotEmpty) {
      params['partyId'] = partyId;
    }
    if (partyName != null && partyName.isNotEmpty) {
      params['partyName'] = partyName;
    }
    if (params.isEmpty) return path;
    return Uri(path: path, queryParameters: params).toString();
  }
}
