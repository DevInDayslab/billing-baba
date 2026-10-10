typedef AccountingSettingsUpdater =
    AccountingSettings Function(AccountingSettings current);

/// Business-scoped accounting feature preferences (device-local persistence).
class AccountingSettings {
  const AccountingSettings({
    required this.enableAccountingModule,
    required this.allowJournalEntries,
  });

  factory AccountingSettings.defaults() => const AccountingSettings(
    enableAccountingModule: false,
    allowJournalEntries: false,
  );

  factory AccountingSettings.fromJson(Map<String, dynamic> json) {
    final defaults = AccountingSettings.defaults();
    return AccountingSettings(
      enableAccountingModule:
          json['enableAccountingModule'] as bool? ??
          defaults.enableAccountingModule,
      allowJournalEntries:
          json['allowJournalEntries'] as bool? ?? defaults.allowJournalEntries,
    );
  }

  final bool enableAccountingModule;
  final bool allowJournalEntries;

  AccountingSettings copyWith({
    bool? enableAccountingModule,
    bool? allowJournalEntries,
  }) {
    return AccountingSettings(
      enableAccountingModule:
          enableAccountingModule ?? this.enableAccountingModule,
      allowJournalEntries: allowJournalEntries ?? this.allowJournalEntries,
    );
  }

  Map<String, dynamic> toJson() => {
    'enableAccountingModule': enableAccountingModule,
    'allowJournalEntries': allowJournalEntries,
  };

  /// Whether journal entries apply only when the accounting module is enabled.
  bool get isJournalEntriesApplicable => enableAccountingModule;

  AccountingSettings withAccountingModuleEnabled(bool enabled) {
    if (enabled) {
      return copyWith(enableAccountingModule: true);
    }
    return copyWith(
      enableAccountingModule: false,
      allowJournalEntries: false,
    );
  }

  /// Turning journal on also enables the accounting module when it was off.
  AccountingSettings withAllowJournalEntries(bool allowed) {
    if (!enableAccountingModule && allowed) {
      return copyWith(
        enableAccountingModule: true,
        allowJournalEntries: true,
      );
    }
    if (!enableAccountingModule) {
      return this;
    }
    return copyWith(allowJournalEntries: allowed);
  }
}
