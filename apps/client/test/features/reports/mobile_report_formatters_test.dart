import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shortens UUID references and keeps short invoice numbers', () {
    expect(
      formatMobileReportReference(
        'CASH',
        '066c7a2b-8bf7-4566-a061-7c2d4862c650',
      ),
      'CASH 066c7a2b…',
    );
    expect(formatMobileReportReference('SALE', '51'), 'SALE 51');
    expect(
      shortenMobileReportReference(
        'CASH 066c7a2b-8bf7-4566-a061-7c2d4862c650',
      ),
      'CASH 066c7a2b…',
    );
  });

  test('formats compact date ranges for mobile filter header', () {
    expect(
      formatMobileReportDateRange(DateTime(2026, 8), DateTime(2026, 8, 31)),
      '01/08/26 – 31/08/26',
    );
  });
}
