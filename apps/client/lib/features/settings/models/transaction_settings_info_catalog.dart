import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';

enum TransactionSettingsInfoKey {
  invoiceBillNo,
  addTimeOnTransactions,
  printTimeOnInvoices,
  cashSaleByDefault,
  billingNameOfParties,
  customersPoDetails,
  inclusiveExclusiveTax,
  displayPurchasePrice,
  showLast5SalePrice,
  showLast5PurchasePrice,
  freeItemQuantity,
  count,
  transactionWiseTax,
  transactionWiseDiscount,
  roundOffTotal,
  eWayBillNo,
  quickEntry,
  doNotShowInvoicePreview,
  repeatInvoices,
  passcodeEditDelete,
  discountDuringPayments,
  linkPaymentsToInvoices,
  dueDatesPaymentTerms,
  showProfitOnSaleInvoice,
  wholesalePriceToggle,
  termsAndConditions,
}

abstract final class TransactionSettingsInfoCatalog {
  static List<SettingsInfoSection> sectionsFor(TransactionSettingsInfoKey key) {
    return switch (key) {
      TransactionSettingsInfoKey.invoiceBillNo => _sections(
        what:
            'Billing Baba will assign invoice/bill numbers automatically to your transactions like sale, expenses etc.',
        how:
            'Invoice/bill numbers will be assigned to every invoice & the no. will keep on increasing as you keep making invoices. You can also change the number manually.',
        why:
            'Keep track of your invoices and assign unique invoice numbers automatically.',
      ),
      TransactionSettingsInfoKey.addTimeOnTransactions => _sections(
        what:
            'This setting allows you to enter the time of transaction along with the date at the time of creating it.',
        how:
            'You can enter the time of the transaction whenever you open a new transaction form or open an existing transaction for edit.',
        why:
            'Time on transaction allows you to keep record of time critical transactions like retail slips. It also allows you to differentiate between two transactions with the same party on the same date.',
      ),
      TransactionSettingsInfoKey.printTimeOnInvoices => _sections(
        what:
            'Enabling this allows you to print the time of transaction on your invoices (both regular and thermal).',
        how:
            'Billing Baba would pick the time entered on the transaction, and show it below the usual date field.',
        why:
            'If you have time critical invoices or want to communicate the time of generation to your users, you can use this setting.',
      ),
      TransactionSettingsInfoKey.cashSaleByDefault => _sections(
        what:
            'All Sale Invoices will be treated as Paid in Full without any pending dues. Billing Baba will allow you to make Sale invoices without selecting any Party too.',
        how:
            'Cash Sale option will be selected by default in Sale Invoices. You can always change it to Credit invoice manually.',
        why:
            'For retailers and businessmen doing over the counter sales where customer pays you the full amount upfront, this setting can be used.',
      ),
      TransactionSettingsInfoKey.billingNameOfParties => _sections(
        what:
            'Enables you to add Billing name in Sale Invoice and Sale Orders. This billing name will be printed in invoices in place of Party name.',
        how:
            'On enabling this, you will be able to enter billing name in transactions to print on invoices.',
        why:
            'Can be used when Customer names are very similar and proper names need to be printed on invoices for every customer.',
      ),
      TransactionSettingsInfoKey.customersPoDetails => _sections(
        what:
            'Enables you to add PO date and PO number in Sale/Purchase Transactions.',
        why: 'It is to track your PO against Sale or Purchase made.',
      ),
      TransactionSettingsInfoKey.inclusiveExclusiveTax => _sections(
        what:
            'You can make the Rate (price/unit) field on transactions to include or exclude tax. You can set inclusive and exclusive tax for sale and purchase separately.',
        how:
            'You can make the Rate (price/unit) to include or exclude the tax for items in any transaction.',
        why:
            'Bills received from vendors or suppliers may have rate either inclusive or exclusive of tax. This setting helps you enter bills and transactions easily for both types of bills.',
      ),
      TransactionSettingsInfoKey.displayPurchasePrice => _sections(
        what:
            'Purchase price of items will be shown in Item list while adding any item to Sale, Purchase etc. transactions.',
        why:
            'This will help you in understanding at what price you bought the item & what should be the margin for selling that item.',
      ),
      TransactionSettingsInfoKey.showLast5SalePrice => _sections(
        what:
            'Billing Baba will show sale prices of last 5 transactions for every item while adding it to Sale transactions.',
        why:
            'You can see at what price you sold the item in last 5 transactions & get an idea about what price you should sell at this time.',
      ),
      TransactionSettingsInfoKey.showLast5PurchasePrice => _sections(
        what:
            'Billing Baba will show purchase prices of last 5 transactions for every item while adding it to purchase transactions.',
        why:
            'You can see at what price you purchased the item in last 5 transactions & get an idea about what selling price should be.',
      ),
      TransactionSettingsInfoKey.freeItemQuantity => _sections(
        what:
            'Once enabled you can add additional free quantity in invoices that you are giving to the Party for free.',
        why:
            'In case you are running a sale offer of Buy 1 get another free, to maintain your stock inventory correctly, you can enable this setting.',
      ),
      TransactionSettingsInfoKey.count => _sections(
        what:
            'Enables you to enter the count of the packets that you have given to the customer separately.',
        how:
            'For eg: 1 sack which has 5kg of Rice & you have given that in separate packets of 1 Kg each.',
      ),
      TransactionSettingsInfoKey.transactionWiseTax => _sections(
        what:
            'Allows you to apply a single tax on entire Sale/Purchase transaction bill instead of applying different taxes on each item.',
        how:
            'You will be able to apply a single tax on all the line items of any transaction. This tax will be applied on subtotal of all the individual line items.',
        why:
            'In case you have same type of stock items having same tax rates, you can enable this setting and easily apply tax just once on invoice for all sold/purchased items together.',
      ),
      TransactionSettingsInfoKey.transactionWiseDiscount => _sections(
        what:
            'Allows you to apply a single discount on full Sale/Purchase transaction bill instead of applying different discounts on each item.',
        how:
            'You will be able to apply a single discount on all the line items of any transaction. This discount will be applied on subtotal of all the individual line items.',
        why:
            'If you are giving discounts on entire Invoice or Bill rather than separate discounts on each stock item, then you can use this option.',
      ),
      TransactionSettingsInfoKey.roundOffTotal => _sections(
        what:
            'By enabling this you get the option to round off amount to the nearest digits selected by you.',
        why:
            'When you do not want any decimal value of the transactions, then you could round off to nearest 1, by selecting it.',
      ),
      TransactionSettingsInfoKey.eWayBillNo => _sections(
        what:
            'To add & generate e-way bills in a single click after you make the invoice, enter your e-way bill portal user name and password.',
        how:
            'You will be able to generate E-way Bills for invoices, just after you have made your invoice. You can share the invoice with the e-way bill no. with your transporter.',
        why:
            'E-way bill is needed by Govt. of India for shipping goods from one place to another.',
      ),
      TransactionSettingsInfoKey.quickEntry => _sections(
        what:
            'An extra row will appear for billing items upon enabling quick entry. You can enter items in the first row, press enter & that item will move to your billed item list.',
        why:
            'You can keep entering items in the 1st row & bill items quickly & make your invoice faster.',
      ),
      TransactionSettingsInfoKey.doNotShowInvoicePreview => _sections(
        what:
            'Preview of Invoice PDF will not be shown every time while making any new invoice.',
      ),
      TransactionSettingsInfoKey.repeatInvoices => _sections(
        what:
            'Create repeat invoices that are generated automatically based on the frequency you set.',
        how:
            'While making a sale invoice, set up a repeat frequency. The system will then create invoices as per the schedule, sent automatically.',
        why:
            'Save time by not creating the same invoice for the same customer repeatedly. With repeat invoices, your invoices are created automatically, on time, every time.',
      ),
      TransactionSettingsInfoKey.passcodeEditDelete => _sections(
        what: 'Set Passcode or Pin for editing or deleting any transaction.',
        why:
            'This will save you from editing or deleting any transaction by mistake and will not allow anyone else to edit or delete any transaction.',
      ),
      TransactionSettingsInfoKey.discountDuringPayments => _sections(
        what:
            'Enables you to add/ track discount during Payment-In and Payment-Out transactions.',
        why:
            'For eg: A customer had to pay you 1000 Rupees but while making the payment, they paid only 900 & you agreed to take 900 then 100 is the discount amount in payment in but the total of bill remains 1000. This amount can be mentioned while doing the payment in transaction.',
      ),
      TransactionSettingsInfoKey.linkPaymentsToInvoices => _sections(
        what:
            'You will be able to link the "Payment In" transactions or money you received to the unpaid invoices/bills of Party. On linking received payment to an invoice it will be marked as "Paid".',
        how:
            'While receiving payments by "Payment In" transaction or while editing any sale/purchase transaction, Billing Baba will show options to Receive and Link Payments.',
        why:
            'Invoice statuses can be tracked from Unpaid, Partially Paid and Paid. Received payments can be linked to invoices for complete tracking.',
      ),
      TransactionSettingsInfoKey.dueDatesPaymentTerms => _sections(
        what:
            'You can enter Due Dates and define Payment Terms on invoices/bills. Billing Baba will also show invoice aging reports that will let you track Paid, Unpaid and Overdue invoices.',
        how:
            'You can define Payment terms and due dates while making invoices/bills. Billing Baba will show them as Overdue if they are not paid by the Due date.',
        why:
            'It is to track overdue payments on sale and purchase invoices. This will also give you sale ageing report, which gives you details about payments which are pending with their due dates.',
      ),
      TransactionSettingsInfoKey.showProfitOnSaleInvoice => _sections(
        what:
            'This allows the user to show profit that they would be making on a particular sale invoice.',
        how:
            'Enabling this setting will add a button on the sale invoice form which will show the cost breakdown and profit to be made on a sale invoice.',
      ),
      TransactionSettingsInfoKey.wholesalePriceToggle => _sections(
        what:
            'This setting allows users to enable or disable wholesale pricing toggle in transaction billing.',
        how:
            'When enabled, Wholesale price will be used for new items added in the bill, bypassing the quantity limit.',
      ),
      TransactionSettingsInfoKey.termsAndConditions => _sections(
        what:
            'Enables you to print Terms and Conditions on Sale Invoices, Delivery Challan, Sale Order, Estimate/Quotation, Purchase and Purchase Order.',
        how:
            'On enabling Terms and Conditions, you will be able to set transaction-specific Terms and Conditions. It will appear in the invoices and you will also be able to customise them for each transaction.',
      ),
    };
  }

  static List<SettingsInfoSection> _sections({
    required String what,
    String? how,
    String? why,
  }) {
    return [
      SettingsInfoSection(title: 'What is this?', body: what),
      if (how != null) SettingsInfoSection(title: 'How it is used?', body: how),
      if (why != null) SettingsInfoSection(title: 'Why to use?', body: why),
    ];
  }
}
