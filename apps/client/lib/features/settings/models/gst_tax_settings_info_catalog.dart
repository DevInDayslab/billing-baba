import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';

enum GstTaxSettingsInfoKey {
  enableGst,
  hsnSac,
  additionalCess,
  reverseCharge,
  placeOfSupply,
  compositeScheme,
  enableTcs,
  enableTds,
}

abstract final class GstTaxSettingsInfoCatalog {
  static List<SettingsInfoSection> sectionsFor(GstTaxSettingsInfoKey key) {
    return switch (key) {
      GstTaxSettingsInfoKey.enableGst => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'GST stands for Goods and Services Tax of Indian Government. Enabling GST allows you to apply GST on Sale, Purchase and other types of transactions.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Apply GST on Sale and/or purchase invoices. Generate GST reports for Tax filing.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'Businesses which have GSTIN no. & are registered under regular or composite scheme can enable GST. Billing Baba will generate readymade GSTR Reports like GSTR - 1, GSTR - 3B for your GST filing in India.',
        ),
      ],
      GstTaxSettingsInfoKey.hsnSac => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables you to enter & track HSN/ SAC code for item.',
        ),
      ],
      GstTaxSettingsInfoKey.additionalCess => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables you to add additional cess on item.',
        ),
      ],
      GstTaxSettingsInfoKey.reverseCharge => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables reverse charge for your purchase transaction.',
        ),
      ],
      GstTaxSettingsInfoKey.placeOfSupply => const [
        SettingsInfoSection(
          title: 'What is this?',
          body: 'Enables you to add place of supply while making transaction.',
        ),
      ],
      GstTaxSettingsInfoKey.compositeScheme => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'Enables Composite Business mode. You will not be allowed to add taxes on transaction if you are under composite Business scheme of GST.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'If your company is registered under Composite GST Scheme, turn this on and select the category of your business: Manufacturing, Trader (Goods), or Restaurant.',
        ),
      ],
      GstTaxSettingsInfoKey.enableTcs => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'TCS or Tax Collected at Source is the tax that vendors collect from their customers at the time of sale.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Enter TCS or Tax Collected at Source in your transactions. Find your TCS details in your Form 27EQ.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'The government requires you to collect TCS if your turnover has exceeded Rs.10 crore in the last financial year and the invoice value of sale to a customer exceeds Rs.50 lakh in the current financial year.',
        ),
      ],
      GstTaxSettingsInfoKey.enableTds => const [
        SettingsInfoSection(
          title: 'What is this?',
          body:
              'TDS or Tax Deducted at Source is the tax deducted by the payer at the time of making specified payments and subsequently deposited with the government.',
        ),
        SettingsInfoSection(
          title: 'How it is used?',
          body:
              'Enter TDS or Tax Deducted at Source in your transactions. Find your TDS details in TDS Receivable and TDS Payable reports.',
        ),
        SettingsInfoSection(
          title: 'Why to use?',
          body:
              'Under the TDS system, a person or entity making specific types of payments is required to deduct a certain percentage of tax from the payment before it is given to the recipient by the government. By utilizing the TDS feature, you can streamline your financial processes, minimize errors, stay compliant with tax regulations, and avoid penalties or legal issues related to tax deductions.',
        ),
      ],
    };
  }
}
