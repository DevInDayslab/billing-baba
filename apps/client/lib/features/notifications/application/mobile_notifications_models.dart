/// Notification center tabs — UI only for now (no backend).
enum MobileNotificationTab {
  appNotifications,
  allTransactions,
}

extension MobileNotificationTabX on MobileNotificationTab {
  String get id => name;

  String get label => switch (this) {
    MobileNotificationTab.appNotifications => 'App Notifications',
    MobileNotificationTab.allTransactions => 'All Transactions',
  };

  String get emptyTitle => switch (this) {
    MobileNotificationTab.appNotifications =>
      'No notifications as of yet. Come back later.',
    MobileNotificationTab.allTransactions =>
      'No transactions as of yet. Come back later.',
  };

  static MobileNotificationTab fromId(String id) {
    return MobileNotificationTab.values.firstWhere(
      (tab) => tab.id == id,
      orElse: () => MobileNotificationTab.appNotifications,
    );
  }
}
