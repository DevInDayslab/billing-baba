/// Desktop Settings hub tabs (in-page; no per-tab routes).
enum SettingsTab {
  profile,
  print,
  transactionMessages,
  backup,
  about;

  String get id => switch (this) {
    SettingsTab.profile => 'profile',
    SettingsTab.print => 'print',
    SettingsTab.transactionMessages => 'transaction-messages',
    SettingsTab.backup => 'backup',
    SettingsTab.about => 'about',
  };

  String get label => switch (this) {
    SettingsTab.profile => 'Business Profile',
    SettingsTab.print => 'Print',
    SettingsTab.transactionMessages => 'Transaction Messages',
    SettingsTab.backup => 'Backup & Restore',
    SettingsTab.about => 'About',
  };

  static SettingsTab fromQuery(String? raw) {
    if (raw == null || raw.isEmpty) return SettingsTab.profile;
    // Back-compat for older deep links.
    if (raw == 'general') return SettingsTab.profile;
    if (raw == 'taxes') return SettingsTab.profile;
    for (final tab in SettingsTab.values) {
      if (tab.id == raw) return tab;
    }
    return SettingsTab.profile;
  }
}
