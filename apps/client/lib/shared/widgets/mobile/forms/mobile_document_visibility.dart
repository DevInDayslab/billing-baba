/// Section visibility for mobile document create forms.
///
/// Pages pass flags based on what the document/provider supports —
/// not hardcoded document-type branches inside section widgets.
class MobileDocumentVisibility {
  const MobileDocumentVisibility({
    this.showDocumentNumber = true,
    this.showDate = true,
    this.showTime = true,
    this.showDueDate = false,
    this.showPaymentTerms = false,
    this.showStateOfSupply = false,
    this.showGodown = false,
    this.showEWayBill = false,
    this.showParty = true,
    this.showBillingName = false,
    this.showPhone = false,
    this.showBillingAddress = false,
    this.showShippingAddress = false,
    this.showGstin = false,
    this.showEmail = false,
    this.showItems = true,
    this.showBarcodeScan = false,
    this.showTotals = true,
    this.showRoundOff = false,
    this.showPaymentSection = false,
    this.showReceivedAmount = false,
    this.showDescription = false,
    this.showTerms = false,
    this.showAttachments = false,
    this.showSaleTypeToggle = false,
    this.showSettings = false,
    this.showSaveAndNew = true,
  });

  final bool showDocumentNumber;
  final bool showDate;
  final bool showTime;
  final bool showDueDate;
  final bool showPaymentTerms;
  final bool showStateOfSupply;
  final bool showGodown;
  final bool showEWayBill;
  final bool showParty;
  final bool showBillingName;
  final bool showPhone;
  final bool showBillingAddress;
  final bool showShippingAddress;
  final bool showGstin;
  final bool showEmail;
  final bool showItems;
  final bool showBarcodeScan;
  final bool showTotals;
  final bool showRoundOff;
  final bool showPaymentSection;
  final bool showReceivedAmount;
  final bool showDescription;
  final bool showTerms;
  final bool showAttachments;
  final bool showSaleTypeToggle;
  final bool showSettings;
  final bool showSaveAndNew;

  /// Sale invoice / bill-of-supply style create form (desktop Add Sale).
  static const saleInvoice = MobileDocumentVisibility(
    showDueDate: true,
    showPaymentTerms: true,
    showStateOfSupply: true,
    showGodown: true,
    showEWayBill: true,
    showBillingName: true,
    showPhone: true,
    showBillingAddress: true,
    showShippingAddress: true,
    showGstin: true,
    showEmail: true,
    showRoundOff: true,
    showPaymentSection: true,
    showReceivedAmount: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
    showSaleTypeToggle: true,
    showSettings: true,
  );

  /// Estimate / proforma (no payment collection on create).
  static const saleDocument = MobileDocumentVisibility(
    showStateOfSupply: true,
    showGodown: true,
    showRoundOff: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
  );

  /// Sale order.
  static const saleOrder = MobileDocumentVisibility(
    showStateOfSupply: true,
    showGodown: true,
    showRoundOff: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
  );

  /// Delivery challan.
  static const deliveryChallan = MobileDocumentVisibility(
    showDueDate: true,
    showStateOfSupply: true,
    showGodown: true,
    showBillingAddress: true,
    showShippingAddress: true,
    showRoundOff: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
  );

  /// Credit note / sale return.
  static const creditNote = MobileDocumentVisibility(
    showStateOfSupply: true,
    showGodown: true,
    showPhone: true,
    showRoundOff: true,
    showPaymentSection: true,
    showDescription: true,
    showAttachments: true,
  );

  /// Purchase bill.
  static const purchaseBill = MobileDocumentVisibility(
    showDueDate: true,
    showPaymentTerms: true,
    showStateOfSupply: true,
    showGodown: true,
    showEWayBill: true,
    showBillingName: true,
    showRoundOff: true,
    showPaymentSection: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
  );

  /// Purchase order.
  static const purchaseOrder = MobileDocumentVisibility(
    showStateOfSupply: true,
    showGodown: true,
    showRoundOff: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
  );

  /// Debit note / purchase return.
  static const debitNote = MobileDocumentVisibility(
    showStateOfSupply: true,
    showGodown: true,
    showRoundOff: true,
    showDescription: true,
    showTerms: true,
    showAttachments: true,
  );

  /// Payment in/out (no line items).
  static const payment = MobileDocumentVisibility(
    showItems: false,
    showPaymentSection: true,
    showDescription: true,
    showAttachments: true,
    showSaveAndNew: false,
  );

  /// Expense.
  static const expense = MobileDocumentVisibility(
    showPaymentSection: true,
    showDescription: true,
    showAttachments: true,
    showSaveAndNew: false,
  );
}
