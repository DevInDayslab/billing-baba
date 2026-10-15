/// Central route path constants.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const verifyOtp = '/verify-otp';
  static const home = '/home';
  static const notifications = '/notifications';
  static const businessList = '/business-list';
  static const parties = '/parties';
  static const partyDetails = '/parties/party-details';
  static const partyGroups = '/parties/groups';
  static const partyHiddenLedger = '/parties/hidden-ledger';
  static String partyContactImport(String token) =>
      '/parties/import-contacts/$token';
  static const crm = '/crm';
  static const crmLeads = '/crm/leads';
  static const crmContacts = '/crm/contacts';
  static const crmDeals = '/crm/deals';
  static const items = '/items';
  static const itemsDetail = '/items/details';
  static const itemsCategories = '/items/categories';
  static const itemsBrands = '/items/brands';
  static const itemsUnits = '/items/units';
  static const itemsGodowns = '/items/godowns';
  static const itemsStockTransfer = '/items/stock-transfer';
  static const itemsSettings = '/items/settings';
  static const pos = '/pos';
  static const sale = '/sale';
  static const saleInvoices = '/sale/invoices';
  static const saleEstimateQuotation = '/sale/estimate-quotation';
  static const saleProformaInvoice = '/sale/proforma-invoice';
  static const salePaymentIn = '/sale/payment-in';
  static const saleCashAndBank = '/sale/cash-and-bank';
  static const addPaymentIn = '/sale/add-payment-in';
  static const saleOrder = '/sale/order';
  static const addSaleOrder = '/sale/add-order';
  static const editSaleOrder = '/sale/edit-order';
  static const saleDeliveryChallan = '/sale/delivery-challan';
  static const addDeliveryChallan = '/sale/add-delivery-challan';
  static const editDeliveryChallan = '/sale/edit-delivery-challan';
  static const saleJobWorkOut = '/sale/job-work-out';
  static const addJobWork = '/sale/add-job-work';
  static const editJobWork = '/sale/edit-job-work';
  static const saleReturnCreditNote = '/sale/return-credit-note';
  static const otherIncome = '/sale/other-income';
  static const addOtherIncome = '/sale/add-other-income';
  static const editOtherIncome = '/sale/edit-other-income';
  static const saleFa = '/sale/fa';
  static const addSaleFa = '/sale/add-fa';
  static const editSaleFa = '/sale/edit-fa';
  static const addCreditNote = '/sale/add-credit-note';
  static const editCreditNote = '/sale/edit-credit-note';
  static const duplicateSale = '/sale/add/duplicate';
  static const addSale = '/sale/add';
  static const saleInvoiceMoreSettings = '/sale/more-settings';
  static const editSale = '/sale/edit';
  static const viewSale = '/sale/view';
  static const addEstimate = '/sale/add-estimate';
  static const duplicateEstimate = '/sale/add-estimate/duplicate';
  static const editEstimate = '/sale/edit-estimate';
  static const addProforma = '/sale/add-proforma';
  static const editProforma = '/sale/edit-proforma';
  static const purchase = '/purchase';
  static const purchaseBills = '/purchase/bills';
  static const purchasePaymentOut = '/purchase/payment-out';
  static const addPaymentOut = '/purchase/add-payment-out';
  static const purchaseExpenses = '/purchase/expenses';
  static const purchaseOrder = '/purchase/order';
  static const purchaseReturnDebitNote = '/purchase/return-debit-note';
  static const addDebitNote = '/purchase/add-debit-note';
  static const purchaseFa = '/purchase/fa';
  static const addPurchaseFa = '/purchase/add-fa';
  static const editPurchaseFa = '/purchase/edit-fa';
  static const addPurchase = '/purchase/add';
  static const editPurchase = '/purchase/edit';
  static const addPurchaseOrder = '/purchase/add-order';
  static const editPurchaseOrder = '/purchase/edit-order';
  static const addExpense = '/purchase/add-expense';
  static const editExpense = '/purchase/edit-expense';
  static const editDebitNote = '/purchase/edit-debit-note';
  static const loanAccounts = '/purchase/loan-accounts';
  static const loanAccountDetail = '/purchase/loan-accounts/detail';
  static const addLoanAccount = '/purchase/add-loan-account';
  static const editLoanAccount = '/purchase/edit-loan-account';
  static const addLoanTransaction = '/purchase/add-loan-transaction';
  static const reports = '/reports';
  static const reportsDashboard = '/reports/dashboard';
  static const reportsSales = '/reports/sales';
  static const reportsPurchase = '/reports/purchase';
  static const reportsStock = '/reports/stock';
  static const reportsStockSummary = '/reports/stock-summary';
  static const reportsItemDetail = '/reports/item-detail';
  static const reportsParty = '/reports/party';
  static const reportsGst = '/reports/gst';
  static const collaboration = '/collaboration';
  static const collaborationSyncShare = '/collaboration/sync-share';
  static const utilities = '/utilities';
  static const utilitiesImportItems = '/utilities/import-items';
  static const utilitiesExportItems = '/utilities/export-items';
  static const utilitiesImportParties = '/utilities/import-parties';
  static const utilitiesAddItemsBarcode = '/utilities/import-items/barcode';
  static const utilitiesBulkUpdateItems = '/utilities/bulk-update-items';
  static const utilitiesBarcodeGenerator = '/utilities/barcode-generator';
  static const utilitiesRecycleBin = '/utilities/recycle-bin';
  static const developer = '/developer';
  static const developerDiagnostics = '/developer/diagnostics';
  static const developerComponents = '/developer/components';
  static const developerComponentsButtons = '/developer/components/buttons';
  static const developerComponentsInputs = '/developer/components/inputs';
  static const developerComponentsDialogs = '/developer/components/dialogs';
  static const developerComponentsDataTables =
      '/developer/components/data-tables';
  static const developerComponentsTableFilters =
      '/developer/components/table-filters';
  static const developerComponentsBadges = '/developer/components/badges';
  static const developerComponentsChips = '/developer/components/chips';
  static const developerComponentsCards = '/developer/components/cards';
  static const developerComponentsTypography =
      '/developer/components/typography';
  static const developerComponentsColors = '/developer/components/colors';
  static const developerComponentsIcons = '/developer/components/icons';
  static const developerComponentsLoading = '/developer/components/loading';
  static const developerComponentsEmptyStates =
      '/developer/components/empty-states';
  static const settings = '/settings';
  static const settingsGeneral = '/settings/general';
  static const settingsTransaction = '/settings/transaction';
  static const settingsTaxes = '/settings/taxes';
  static const settingsPreferences = '/settings/preferences';
  static const settingsPrint = '/settings/print';
  static const settingsTransactionMessages = '/settings/transaction-messages';
  static const settingsParty = '/settings/party';
  static const settingsServiceReminders = '/settings/service-reminders';
  static const settingsAccounting = '/settings/accounting';
  static const settingsMultiCurrency = '/settings/multi-currency';
  static const settingsBackup = '/settings/backup';
  static const settingsNotifications = '/settings/notifications';
  static const settingsReports = '/settings/reports';

  static String settingsReportGroup(String groupId) =>
      '$settingsReports/$groupId';

  static String settingsReportSubsection(String groupId, String subsectionId) =>
      '${settingsReportGroup(groupId)}/$subsectionId';

  /// Settings hub deep-link with tab query (`general`, `print`, …).
  static String settingsTab(String tabId) => '$settingsPreferences?tab=$tabId';

  static const plansPricing = '/plans-pricing';

  /// Fast counter billing. Kept off the `/sale` prefix so it does not expand
  /// the Sale document group in the sidebar.
  static const saleScreen = '/sale-screen';
  static const subscriptionReview = '/plans-pricing/review';
  static const subscriptionPaymentProcessing =
      '/plans-pricing/payment-processing';
  static const subscriptionPaymentSuccess = '/plans-pricing/payment-success';
  static const plansPricingLicenseInfo = '/plans-pricing/license-info';
  static const editProfile = '/edit-profile';
  static const userProfile = '/my-profile';
  static const accessDenied = '/access-denied';

  /// Sale transaction add/edit/view flows use the full window (no shell sidebar/top bar).
  static bool isSaleInvoiceFormRoute(String path) {
    const exactFormRoutes = <String>{
      addSale,
      saleScreen,
      addEstimate,
      addProforma,
      addSaleOrder,
      addDeliveryChallan,
      addCreditNote,
      addSaleFa,
      addPaymentIn,
      addJobWork,
    };
    if (exactFormRoutes.contains(path)) return true;

    const pathPrefixes = <String>[
      duplicateSale,
      editSale,
      viewSale,
      duplicateEstimate,
      editEstimate,
      editProforma,
      editSaleOrder,
      editDeliveryChallan,
      editCreditNote,
      editSaleFa,
      editJobWork,
    ];
    for (final prefix in pathPrefixes) {
      if (path == prefix || path.startsWith('$prefix/')) return true;
    }
    return false;
  }
}
