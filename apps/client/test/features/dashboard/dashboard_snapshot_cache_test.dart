import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/dashboard/data/dashboard_snapshot_cache.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardSnapshotCache', () {
    late _FakeStorage storage;
    late DashboardSnapshotCache cache;

    setUp(() {
      storage = _FakeStorage({});
      cache = DashboardSnapshotCache(storage);
    });

    test('saves and reads snapshot per business and period', () {
      cache.save(
        businessId: 'biz-1',
        period: DashboardPeriod.thisMonth,
        payload: {
          'generated_at': '2026-01-15T10:00:00Z',
          'period': {
            'period': 'this_month',
            'from': '2026-01-01',
            'to': '2026-01-31',
          },
          'overview': {
            'total_receivable': '1000',
            'receivable_party_count': 2,
            'total_payable': '500',
            'payable_party_count': 1,
          },
          'sales': {
            'total_amount': '2000',
            'invoice_count': 3,
            'received_amount': '1500',
            'balance_amount': '500',
          },
          'purchases': {
            'total_amount': '800',
            'bill_count': 2,
          },
          'finance': {
            'cash_in': '1500',
            'cash_out': '800',
            'expenses': '200',
          },
          'inventory': {
            'total_stock_value': '5000',
            'low_stock_count': 1,
            'negative_stock_count': 0,
            'low_stock_items': <dynamic>[],
          },
          'charts': {
            'sales_trend': {'granularity': 'day', 'points': <dynamic>[]},
            'purchases_trend': {'granularity': 'day', 'points': <dynamic>[]},
          },
          'alerts': <dynamic>[],
          'recent_transactions': <dynamic>[],
          'quick_reports': <dynamic>[],
        },
      );

      final read = cache.read(
        businessId: 'biz-1',
        period: DashboardPeriod.thisMonth,
      );

      expect(read, isNotNull);
      expect(read!.dto.overview.totalReceivable, '1000');
      expect(read.dto.sales.invoiceCount, 3);
    });

    test('returns null for different period', () {
      cache.save(
        businessId: 'biz-1',
        period: DashboardPeriod.today,
        payload: {
          'generated_at': '2026-01-15T10:00:00Z',
          'period': {'period': 'today', 'from': '', 'to': ''},
          'overview': {
            'total_receivable': '0',
            'receivable_party_count': 0,
            'total_payable': '0',
            'payable_party_count': 0,
          },
          'sales': {
            'total_amount': '0',
            'invoice_count': 0,
            'received_amount': '0',
            'balance_amount': '0',
          },
          'purchases': {'total_amount': '0', 'bill_count': 0},
          'finance': {'cash_in': '0', 'cash_out': '0', 'expenses': '0'},
          'inventory': {
            'total_stock_value': '0',
            'low_stock_count': 0,
            'negative_stock_count': 0,
            'low_stock_items': <dynamic>[],
          },
          'charts': {
            'sales_trend': {'granularity': 'day', 'points': <dynamic>[]},
            'purchases_trend': {'granularity': 'day', 'points': <dynamic>[]},
          },
          'alerts': <dynamic>[],
          'recent_transactions': <dynamic>[],
          'quick_reports': <dynamic>[],
        },
      );

      expect(
        cache.read(businessId: 'biz-1', period: DashboardPeriod.thisMonth),
        isNull,
      );
    });
  });
}

class _FakeStorage extends StorageService {
  _FakeStorage(this._values);

  final Map<String, String> _values;

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
