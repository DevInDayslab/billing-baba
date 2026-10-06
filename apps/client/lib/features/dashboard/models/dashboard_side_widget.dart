/// Toggleable widgets shown in the dashboard right column.
enum DashboardSideWidget {
  purchases,
  expenses,
  lowStock,
  stockValue,
  cashInHand,
  bankBalance;

  String get id => name;

  String get label => switch (this) {
    DashboardSideWidget.purchases => 'Purchases',
    DashboardSideWidget.expenses => 'Expenses',
    DashboardSideWidget.lowStock => 'Low Stocks Items',
    DashboardSideWidget.stockValue => 'Stock Value',
    DashboardSideWidget.cashInHand => 'Cash In Hand',
    DashboardSideWidget.bankBalance => 'Total Bank Balance',
  };

  static DashboardSideWidget? fromId(String id) {
    for (final widget in DashboardSideWidget.values) {
      if (widget.id == id) return widget;
    }
    return null;
  }

  static Set<DashboardSideWidget> fromIds(Iterable<String> ids) {
    return fromIdsOrdered(ids).toSet();
  }

  /// Preserves persisted insertion order.
  static List<DashboardSideWidget> fromIdsOrdered(Iterable<String> ids) {
    return ids.map(fromId).whereType<DashboardSideWidget>().toList();
  }

  /// Pins Low Stocks first when enabled without changing saved order.
  static List<DashboardSideWidget> pinLowStockFirst(
    List<DashboardSideWidget> widgets,
  ) {
    const target = DashboardSideWidget.lowStock;
    if (!widgets.contains(target)) return widgets;
    final index = widgets.indexOf(target);
    if (index <= 0) return widgets;
    return [target, ...widgets.where((widget) => widget != target)];
  }
}

/// Top-level tabs on the home/dashboard screen.
enum DashboardHomeTab {
  dashboard,
  searchProductOnline,
  myOnlineStore,
  messages;

  static const tabBarTabs = <DashboardHomeTab>[
    dashboard,
    searchProductOnline,
    myOnlineStore,
    messages,
  ];

  String get label => switch (this) {
    DashboardHomeTab.dashboard => 'Dashboard',
    DashboardHomeTab.searchProductOnline => 'Search Product Online',
    DashboardHomeTab.myOnlineStore => 'My Online Store',
    DashboardHomeTab.messages => 'Messages',
  };
}
