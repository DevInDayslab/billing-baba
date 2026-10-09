/// Keys for general-settings info dialogs.
enum GeneralSettingsInfoKey {
  enablePasscode,
  businessCurrency,
  amountDecimalPlaces,
  gstinNumber,
  stopSaleOnNegativeStock,
  blockNewItemsFromTxnForm,
  blockNewPartiesFromTxnForm,
  autoBackup,
  lastBackup,
  auditTrail,
  estimateQuotation,
  proformaInvoice,
  salePurchaseOrder,
  otherIncome,
  fixedAssets,
  deliveryChallan,
  deliveryChallanGoodsReturn,
  deliveryChallanPrintAmount,
  stockTransferGodowns,
}

class SettingsInfoSection {
  const SettingsInfoSection({required this.title, required this.body});

  final String title;
  final String body;
}

abstract final class GeneralSettingsInfoCatalog {
  static List<SettingsInfoSection> sectionsFor(GeneralSettingsInfoKey key) {
    return switch (key) {
      GeneralSettingsInfoKey.enablePasscode => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Enabling this will ask you to set up passcode for the app.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'If you have set passcode basis user role then users role passcode will be asked on priority & app level passcode will not be asked on app launch.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body: 'Only you can open the app & see your business data.',
        ),
      ],
      GeneralSettingsInfoKey.businessCurrency => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: "Select your Currency's symbol.",
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Currency symbol will be printed on all your transactions like sale, purchase, expenses etc.',
        ),
      ],
      GeneralSettingsInfoKey.amountDecimalPlaces => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Specify the number of digits after decimal for amounts. Amounts will be printed with these decimal places.',
        ),
      ],
      GeneralSettingsInfoKey.gstinNumber => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'You can enter GSTIN of the party while adding a party to Vyapar. This GSTIN will be printed on invoices to the parties.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'In case you want Party\'s GSTIN no. to be printed on invoice then you can enable this.',
        ),
      ],
      GeneralSettingsInfoKey.stopSaleOnNegativeStock => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'This setting stops all users of the company to create a sale if any item is becoming less than 0 quantity after the sale.',
        ),
      ],
      GeneralSettingsInfoKey.blockNewItemsFromTxnForm => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'This setting blocks you from creating an item instantly without going through the item creation process.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'You will not be able to create an item instantly without going through the item creation process.',
        ),
      ],
      GeneralSettingsInfoKey.blockNewPartiesFromTxnForm => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'This setting blocks you from creating a party instantly without going through the party creation process.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'You will not be able to create a party instantly without going through the party creation process.',
        ),
      ],
      GeneralSettingsInfoKey.autoBackup => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Takes backup of your data automatically on your personal google drive.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Vyapar will automatically save your data on your Google drive if internet connection is available.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body: 'To keep your Data safe with you in your google drive.',
        ),
      ],
      GeneralSettingsInfoKey.lastBackup => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'The date & time at which the last back up was taken in your google drive.',
        ),
      ],
      GeneralSettingsInfoKey.auditTrail => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Allows you to record changes that happen to transactions entered on Vyapar.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Audit Trail is used to keep a track of edits made to transactions. Once this setting is enabled, users will see a ‘View History’ option on the invoices which will show all the changes.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'It allows you to have a greater control and visibility over changes happening to the transactions.',
        ),
      ],
      GeneralSettingsInfoKey.estimateQuotation => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables the feature for generating Estimate/Quotation.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Vyapar will show Estimate/Quotation transaction on enabling this setting.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'You can make Estimates or Quotation and share them with your parties. You can easily convert an estimate/quotation into sale invoice anytime.',
        ),
      ],
      GeneralSettingsInfoKey.proformaInvoice => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables the feature for generating Proforma Invoice.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Vyapar will show Proforma Invoice transaction on enabling this setting.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'You can make Proforma Invoices and share them with your parties. You can easily convert a Proforma Invoice into sale invoice anytime.',
        ),
      ],
      GeneralSettingsInfoKey.salePurchaseOrder => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Allows you to make Sale/ Purchase orders and convert them to Sale Invoices/Purchase Bills.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Vyapar will allow you to make Sale and Purchase order transactions on enabling this setting.',
        ),
      ],
      GeneralSettingsInfoKey.otherIncome => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'You can maintain income from other sources apart from your direct business in Vyapar. This income will be shown in your Profit and Loss report.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Enabling this settings will show "Other Income" type of transaction. You can use it for maintaining other incomes in Vyapar.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'To track incomes from various sources other than your primary business at one place. E.g. Rent received etc.',
        ),
      ],
      GeneralSettingsInfoKey.fixedAssets => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Fixed assets are company-owned, long-term tangible assets, such as forms of property or equipment. These assets make up its day-to-day operations to generate income. Being fixed means they can\'t be consumed or converted into cash within a year.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'You can use this setting to keep track of all your fixed assets along with their appreciation and depreciation. You will also get detailed reports based on your fixed assets.',
        ),
      ],
      GeneralSettingsInfoKey.deliveryChallan => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables the feature for generating Delivery Challans.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Vyapar will show Delivery Challan transaction on enabling this setting.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'You can make Delivery Challans and share them with your parties. You can easily convert a Delivery Challan into sale invoice anytime.',
        ),
      ],
      GeneralSettingsInfoKey.deliveryChallanGoodsReturn => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Enables you to specify goods returned from the customer & mention only those goods that are actually sold while converting Delivery Challan to sale invoice.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'While converting Delivery Challan to a Sale invoice, you can specify the quantity of items returned or not delivered to your Party.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'If your party do not accept full delivery or returns some defective items back, you can easily enter them in Vyapar while converting a Delivery Challan to a Sale Invoice.',
        ),
      ],
      GeneralSettingsInfoKey.deliveryChallanPrintAmount => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Enables you to print amount, description and tax details on Delivery Challan.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'This allows you to turn on total amount or pricing detail in Delivery Challan. This setting can be turned off if you dont want your transporter to know about the pricing of the transaction.',
        ),
      ],
      GeneralSettingsInfoKey.stockTransferGodowns => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Manage all your stores/godowns and transfer stock seamlessly between them. Using this feature, you can transfer stock between stores/godowns and manage your inventory more efficiently.',
        ),
      ],
    };
  }
}
