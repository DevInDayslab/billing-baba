/// API endpoint path constants.
abstract final class ApiEndpoints {
  static const auth = '/api/v1/auth';
  static const businesses = '/api/v1/businesses';
  static String business(String id) => '$businesses/$id';
  static const businessProfile = '/api/v1/business/profile';
  static const businessLogo = '/api/v1/business/logo';
  static const businessSignature = '/api/v1/business/signature';
  static const businessStamp = '/api/v1/business/stamp';
  static const businessUpiQr = '/api/v1/business/upi-qr';
  static const authAvatar = '/api/v1/auth/me/avatar';
  static const parties = '/api/v1/parties';
  static String party(String id) => '/api/v1/parties/$id';
  static String partyDeleteStatus(String id) => '/api/v1/parties/$id/delete-status';
  static String partyLedger(String id) => '/api/v1/parties/$id/ledger';
  static String partyLoyalty(String id) => '/api/v1/parties/$id/loyalty';
  static String partyLoyaltyTransactions(String id) =>
      '/api/v1/parties/$id/loyalty/transactions';
  static const settings = '/api/v1/settings';
  static const loyaltyRules = '$settings/loyalty-rules';
  static const crmLeads = '/api/v1/crm/leads';
  static String crmLead(String id) => '/api/v1/crm/leads/$id';
  static String crmLeadActivities(String id) =>
      '/api/v1/crm/leads/$id/activities';
  static const crmContacts = '/api/v1/crm/contacts';
  static String crmContact(String id) => '/api/v1/crm/contacts/$id';
  static String crmContactActivities(String id) =>
      '/api/v1/crm/contacts/$id/activities';
  static const crmDeals = '/api/v1/crm/deals';
  static String crmDeal(String id) => '/api/v1/crm/deals/$id';
  static const sync = '/api/v1/sync';
  static const health = '/api/v1/health';

  static const inventory = '/api/v1/inventory';
  static const inventoryCategories = '$inventory/categories';
  static String inventoryCategory(String id) => '$inventoryCategories/$id';

  static const inventoryBrands = '$inventory/brands';
  static String inventoryBrand(String id) => '$inventoryBrands/$id';

  static const inventoryUnits = '$inventory/units';
  static String inventoryUnit(String id) => '$inventoryUnits/$id';

  static const inventoryUnitConversions = '$inventory/unit-conversions';
  static String inventoryUnitConversion(String id) =>
      '$inventoryUnitConversions/$id';

  static const inventoryGodowns = '$inventory/godowns';
  static String inventoryGodown(String id) => '$inventoryGodowns/$id';

  static const inventoryItems = '$inventory/items';
  static String inventoryItem(String id) => '$inventoryItems/$id';
  static String inventoryItemImages(String itemId) =>
      '${inventoryItem(itemId)}/images';
  static String inventoryItemImage(String itemId, String imageId) =>
      '${inventoryItemImages(itemId)}/$imageId';
  static String inventoryItemImagesReorder(String itemId) =>
      '${inventoryItemImages(itemId)}/reorder';
  static String inventoryItemLocationPhoto(String locationId) =>
      '${inventoryItemLocation(locationId)}/photo';

  static const documentAttachments = '/api/v1/document-attachments';
  static String documentAttachmentsFor(String entityType, String entityId) =>
      '$documentAttachments?entity_type=$entityType&entity_id=$entityId';
  static String documentAttachment(String id) => '$documentAttachments/$id';
  static String documentAttachmentDownloadUrl(String id) =>
      '$documentAttachments/$id/url';

  static const storageImages = '/api/v1/storage/images';
  static String storageImageVariants(String sourceAssetId) =>
      '$storageImages/$sourceAssetId/variants';
  static String storageImageVariantUrl(String sourceAssetId, String variant) =>
      '$storageImages/$sourceAssetId/variants/$variant/url';

  static String inventoryItemTierPrices(String itemId) =>
      '${inventoryItem(itemId)}/tier-prices';
  static String inventoryItemTierPrice(String itemId, String tier) =>
      '${inventoryItemTierPrices(itemId)}/$tier';
  static String inventoryItemPriceHistory(String itemId) =>
      '${inventoryItem(itemId)}/price-history';

  static const inventoryItemLocations = '$inventory/item-locations';
  static String inventoryItemLocation(String id) =>
      '$inventoryItemLocations/$id';

  static const inventoryStockLevels = '$inventory/stock-levels';
  static String inventoryStockLevel(String id) => '$inventoryStockLevels/$id';

  static const inventoryMovements = '$inventory/movements';
  static String inventoryMovement(String id) => '$inventoryMovements/$id';

  static const inventoryPriceHistory = '$inventory/price-history';
  static String inventoryPriceHistoryRecord(String id) =>
      '$inventoryPriceHistory/$id';

  static const barcodeGeminiLookup = '$inventory/barcode/lookup';

  static const sales = '/api/v1/sales';
  static const salesDocuments = '$sales/sales-documents';
  static const fixedAssetSales = '$sales/fixed-asset-sales';
  static String fixedAssetSale(String batchId) => '$fixedAssetSales/$batchId';
  static String salesDocument(String id) => '$salesDocuments/$id';
  static String salesDocumentLines(String id) => '${salesDocument(id)}/lines';
  static String salesDocumentLine(String id, String lineId) =>
      '${salesDocumentLines(id)}/$lineId';
  static String salesDocumentFinalize(String id) =>
      '${salesDocument(id)}/finalize';
  static String salesDocumentCancel(String id) => '${salesDocument(id)}/cancel';
  static String salesDocumentConvert(String id) =>
      '${salesDocument(id)}/convert';
  static String salesDocumentBrandSwap(String id) =>
      '${salesDocument(id)}/brand-swap';
  static String salesDocumentShare(String id) => '${salesDocument(id)}/share';
  static String salesDocumentNotify(String id) => '${salesDocument(id)}/notify';

  static String partyReminders(String id) => '$parties/$id/reminders';

  static const notifications = '/api/v1/notifications';
  static const notificationsStatus = '$notifications/status';
  static const notificationsTest = '$notifications/test';

  static String paymentNotify(String id) => '${payment(id)}/notify';

  static const posSessions = '$sales/pos-sessions';
  static String posSession(String id) => '$posSessions/$id';
  static String posSessionDocuments(String id) =>
      '${posSession(id)}/sales-documents';

  static const accounting = '/api/v1/accounting';
  static const payments = '$accounting/payments';
  static String payment(String id) => '$payments/$id';
  static String paymentAllocations(String id) => '${payment(id)}/allocations';
  static String paymentAllocation(String id, String allocationId) =>
      '${paymentAllocations(id)}/$allocationId';

  static const purchases = '/api/v1/purchases';
  static const purchaseParseDocument = '$purchases/parse-document';
  static const purchaseDocuments = '$purchases/purchase-documents';
  static String purchaseDocument(String id) => '$purchaseDocuments/$id';
  static String purchaseDocumentLines(String id) =>
      '${purchaseDocument(id)}/lines';
  static String purchaseDocumentLine(String id, String lineId) =>
      '${purchaseDocumentLines(id)}/$lineId';
  static String purchaseDocumentFinalize(String id) =>
      '${purchaseDocument(id)}/finalize';
  static String purchaseDocumentCancel(String id) =>
      '${purchaseDocument(id)}/cancel';
  static String purchaseDocumentConvert(String id) =>
      '${purchaseDocument(id)}/convert';
  static String purchaseDocumentPaymentHistory(String id) =>
      '${purchaseDocument(id)}/payment-history';

  static const expenses = '$purchases/expenses';
  static String expense(String id) => '$expenses/$id';
  static const expenseCategories = '$purchases/expense-categories';
  static String expenseCategory(String id) => '$expenseCategories/$id';

  static const fixedAssetPurchases = '$purchases/fixed-asset-purchases';
  static String fixedAssetPurchase(String batchId) =>
      '$fixedAssetPurchases/$batchId';

  static const jobWork = '/api/v1/job-work';
  static const jobWorkOrders = '$jobWork/job-work-orders';
  static String jobWorkOrder(String id) => '$jobWorkOrders/$id';

  static const dashboard = '/api/v1/dashboard';

  static const reports = '/api/v1/reports';
  static const reportsSales = '$reports/sales';
  static const reportsPurchases = '$reports/purchases';
  static const reportsStockSummary = '$reports/stock-summary';
  static const reportsLowStock = '$reports/low-stock';
  static const reportsPartyOutstanding = '$reports/party-outstanding';
  static const reportsPartyStatement = '$reports/party-statement';
  static const reportsDayBook = '$reports/day-book';
  static const reportsAllTransactions = '$reports/all-transactions';
  static const reportsProfitLoss = '$reports/profit-loss';
  static const reportsGstr1 = '$reports/gstr-1';
  static const reportsGstr2 = '$reports/gstr-2';
  static const reportsGstr3b = '$reports/gstr-3b';
  static const reportsBillWiseProfit = '$reports/bill-wise-profit';
  static const reportsCashFlow = '$reports/cash-flow';
  static const reportsPartyWiseProfitLoss = '$reports/party-wise-profit-loss';
  static const reportsPartyReportByItem = '$reports/party-report-by-item';
  static const reportsSalePurchaseByParty = '$reports/sale-purchase-by-party';
  static const reportsSalePurchaseByPartyGroup =
      '$reports/sale-purchase-by-party-group';
  static const reportsGstr9 = '$reports/gstr-9';
  static const reportsSaleSummaryByHsn = '$reports/sale-summary-by-hsn';
  static const reportsSacReport = '$reports/sac-report';
  static const reportsItemReportByParty = '$reports/item-report-by-party';
  static const reportsItemWiseProfitLoss = '$reports/item-wise-profit-loss';
  static const reportsStockDetail = '$reports/stock-detail';
  static const reportsItemDetail = '$reports/item-detail';
  static const reportsSalePurchaseByItemCategory =
      '$reports/sale-purchase-by-item-category';
  static const reportsStockSummaryByItemCategory =
      '$reports/stock-summary-by-item-category';
  static const reportsItemCategoryWiseProfitLoss =
      '$reports/item-category-wise-profit-loss';
  static const reportsItemWiseDiscount = '$reports/item-wise-discount';
  static const reportsManufacturing = '$reports/manufacturing';
  static const reportsConsumption = '$reports/consumption';
  static const reportsStockTransfer = '$reports/stock-transfer';
  static const reportsBankStatement = '$reports/bank-statement';
  static const reportsGstReport = '$reports/gst-report';
  static const reportsGstRateReport = '$reports/gst-rate-report';
  static const reportsForm27eq = '$reports/form-27eq';
  static const reportsTcsReceivable = '$reports/tcs-receivable';
  static const reportsTdsPayable = '$reports/tds-payable';
  static const reportsTdsReceivable = '$reports/tds-receivable';
  static const reportsExpenses = '$reports/expenses';
  static const reportsExpenseByCategory = '$reports/expense-by-category';
  static const reportsExpenseByItem = '$reports/expense-by-item';
  static const reportsSalePurchaseOrders = '$reports/sale-purchase-orders';
  static const reportsSalePurchaseOrderItems =
      '$reports/sale-purchase-order-items';
  static const reportsOtherIncome = '$reports/other-income';
  static const reportsOtherIncomeByCategory =
      '$reports/other-income-by-category';
  static const reportsOtherIncomeByItem = '$reports/other-income-by-item';
  static const reportsLoanStatement = '$reports/loan-statement';
  static const reportsTrialBalance = '$reports/trial-balance';
  static const reportsBalanceSheet = '$reports/balance-sheet';

  static const generatedDocuments = '/api/v1/generated-documents';
  static const generatedDocumentsLookup = '$generatedDocuments/lookup';
  static const generatedDocumentsEnsure = '$generatedDocuments/ensure';
  static String generatedDocumentUrl(String id) => '$generatedDocuments/$id/url';
  static String generatedDocumentRegenerate(String id) =>
      '$generatedDocuments/$id/regenerate';

  static const collaboration = '/api/v1/collaboration';
  static const collaborationInvitations = '$collaboration/invitations';
  static const collaborationCompaniesShared =
      '$collaboration/companies/shared';
  static const collaborationCompaniesInvitations =
      '$collaboration/companies/invitations';
  static const collaborationMembers = '$collaboration/company-members';
  static String collaborationMember(String memberId) =>
      '$collaborationMembers/$memberId';
  static String collaborationReinvite(String invitationId) =>
      '$collaborationInvitations/reinvite/$invitationId';
  static String collaborationCancelInvitation(String invitationId) =>
      '$collaborationInvitations/$invitationId/cancel';
  static String collaborationInvitationByToken(String token) =>
      '$collaborationInvitations/$token';
  static String collaborationAcceptInvitation(String token) =>
      '$collaborationInvitations/$token/accept';
  static String collaborationRejectInvitation(String token) =>
      '$collaborationInvitations/$token/reject';
  static String collaborationLeaveCompany(String memberId) =>
      '$collaboration/company-members/$memberId/leave';
}
