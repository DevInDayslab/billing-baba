import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';

enum AccountingSettingsInfoKey {
  enableAccountingModule,
  allowJournalEntries,
}

abstract final class AccountingSettingsInfoCatalog {
  static List<SettingsInfoSection> sectionsFor(AccountingSettingsInfoKey key) {
    return switch (key) {
      AccountingSettingsInfoKey.enableAccountingModule => _sections(
        what:
            'You can enable this setting to view accounting module in Vyapar. '
            'This module is meant for advanced accounting users who wish to '
            'check/manage their business like an accountant.',
        how:
            'Enabling this setting enables the accountant module on the homepage. '
            'There you can create new accounts as per your requirements, and can '
            'create journal entries inside those accounts.',
        why:
            'Using this, you can create manual accounts and entries that are not '
            'possible to create via regular transactions in Vyapar. For e.g., '
            'Adding a second partner to business, Investments, etc.',
      ),
      AccountingSettingsInfoKey.allowJournalEntries => _sections(
        what:
            'Journal entries are manual transactions, where you can debit any '
            'account, and credit that balance to any other account.',
        how:
            'Enabling this setting unlocks journal entries under accountant module. '
            'Here you can select list of accounts that you want to debit against '
            'the accounts that you want to credit.',
        why:
            'Using this, you can create manual accounts and entries that are not '
            'possible to create via regular transactions in Vyapar. For e.g., tax '
            "entries, Managing owner's equity and so on.",
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
