import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/utils/dashboard_trend_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardTrendSeries', () {
    test('thisMonth builds one bucket per calendar day', () {
      final buckets = DashboardTrendSeries.buildTrendBuckets(
        DashboardPeriod.thisMonth,
        now: DateTime(2026, 10, 16),
      );
      expect(buckets.length, 31);
      expect(buckets.first, DateTime(2026, 10, 1));
      expect(buckets.last, DateTime(2026, 10, 31));
    });

    test('mergeTrendPoints fills missing days with zero', () {
      final buckets = [
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3),
      ];
      final sparse = [
        DashboardTrendPointModel(date: DateTime(2026, 10, 2), amount: 500),
      ];

      final merged = DashboardTrendSeries.mergeTrendPoints(
        buckets,
        sparse,
        DashboardPeriod.thisMonth,
      );

      expect(merged.map((p) => p.amount), [0, 500, 0]);
    });

    test('normalizeDashboardTrend returns dense zero series when sparse empty', () {
      final query = const DashboardQuery(period: DashboardPeriod.thisMonth);
      final normalized = DashboardTrendSeries.normalizeDashboardTrend(
        const [],
        query,
        now: DateTime(2026, 10, 16),
      );

      expect(normalized.length, 31);
      expect(normalized.every((p) => p.amount == 0), isTrue);
    });

    test('combineSparseTrendSources prefers later source for same day', () {
      final remote = [
        DashboardTrendPointModel(date: DateTime(2026, 10, 5), amount: 100),
      ];
      final local = [
        DashboardTrendPointModel(date: DateTime(2026, 10, 5), amount: 250),
      ];

      final combined = DashboardTrendSeries.combineSparseTrendSources(
        [remote, local],
        DashboardPeriod.thisMonth,
      );

      expect(combined.length, 1);
      expect(combined.first.amount, 250);
    });
  });
}
