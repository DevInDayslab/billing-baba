import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';

enum PartySettingsInfoKey {
  partyGrouping,
  shippingAddress,
  printShippingAddress,
  managePartyStatus,
  enablePaymentReminder,
  paymentReminderDueDays,
  additionalFields,
  enableLoyaltyPoint,
}

abstract final class PartySettingsInfoCatalog {
  static List<SettingsInfoSection> sectionsFor(PartySettingsInfoKey key) {
    return switch (key) {
      PartySettingsInfoKey.partyGrouping => _sections(
        what:
            'You can group similar type of parties together. You can make groups and assign parties to the groups.',
        why:
            'If you want to create groups of Customers, Vendors or Region wise Customers & see reports based on groups then you can enable this setting.',
      ),
      PartySettingsInfoKey.shippingAddress => _sections(
        what: 'Enables you to add shipping address for the party.',
        why:
            'There are Parties for which Billing address is different than shipping address then it is important to mention the shipping address so that the items are delivered at the shipping address only.',
      ),
      PartySettingsInfoKey.printShippingAddress => _sections(
        what:
            'Enables you to print shipping address of the party on invoices/bills.',
        why:
            'If there are Parties for which Billing address is different than shipping address then it is important to print the shipping address so that the items are delivered at the shipping address only.',
      ),
      PartySettingsInfoKey.managePartyStatus => _sections(
        what:
            'Manage the active status of a party without deleting their transactions.',
        why:
            'If you deactivate a party, they will move to the bottom of your list. All transactions will be retained with no changes to your reports, and the party will be removed from the billing list dropdown. However, you can still create bills for them if needed.',
      ),
      PartySettingsInfoKey.enablePaymentReminder => _sections(
        what:
            'Enables you to get automatic payment reminders that will help you follow up with your parties & get paid faster.',
      ),
      PartySettingsInfoKey.paymentReminderDueDays => _sections(
        what:
            'Vyapar will remind you of due payments from inactive parties. Specify the number of days of inactivity by them.',
      ),
      PartySettingsInfoKey.additionalFields => _sections(
        what:
            'Add custom fields on party profiles and choose whether each field appears on printed documents.',
        how:
            'Enable a field, set its label, and turn on Show In Print when you want it on invoices and bills.',
      ),
      PartySettingsInfoKey.enableLoyaltyPoint => _sections(
        what:
            'Reward your customers with loyalty program. They earn points for each purchase and later redeem it as discount on their next purchases keeping them coming back for more.',
        how:
            'Setup loyalty by adding reward and redemption rate and other additional features like point expiry. Once setup is complete, every purchase of user will help your users get points that can be redeemed in later purchases.',
        why:
            'Loyalty points program helps in bringing customers back. By giving rewards for shopping, it makes customers happy and more likely to choose your store again.',
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
