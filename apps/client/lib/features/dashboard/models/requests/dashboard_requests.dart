class DashboardQuery {
  const DashboardQuery({
    this.period = DashboardPeriod.thisMonth,
    this.from,
    this.to,
  });

  final DashboardPeriod period;
  final DateTime? from;
  final DateTime? to;

  Map<String, String> toQueryParameters() {
    final params = <String, String>{'period': period.apiValue};
    if (period == DashboardPeriod.custom) {
      if (from != null) params['from'] = from!.toUtc().toIso8601String();
      if (to != null) params['to'] = to!.toUtc().toIso8601String();
    }
    return params;
  }
}

enum DashboardPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  allTime,
  custom;

  String get label => switch (this) {
    DashboardPeriod.today => 'Today',
    DashboardPeriod.thisWeek => 'This Week',
    DashboardPeriod.thisMonth => 'This Month',
    DashboardPeriod.thisYear => 'This Year',
    DashboardPeriod.allTime => 'All Time',
    DashboardPeriod.custom => 'Custom',
  };

  String get apiValue => switch (this) {
    DashboardPeriod.today => 'today',
    DashboardPeriod.thisWeek => 'this_week',
    DashboardPeriod.thisMonth => 'this_month',
    DashboardPeriod.thisYear => 'this_year',
    DashboardPeriod.allTime => 'all_time',
    DashboardPeriod.custom => 'custom',
  };

  static DashboardPeriod fromApiValue(String value) => switch (value) {
    'today' => DashboardPeriod.today,
    'this_week' => DashboardPeriod.thisWeek,
    'this_year' => DashboardPeriod.thisYear,
    'all_time' => DashboardPeriod.allTime,
    'custom' => DashboardPeriod.custom,
    _ => DashboardPeriod.thisMonth,
  };
}
