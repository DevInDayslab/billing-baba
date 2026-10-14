import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';
import 'package:billing_baba/shared/documents/transaction_round_off.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyTransactionRoundOff', () {
    test('nearest to 1 removes decimals', () {
      expect(
        applyTransactionRoundOff(
          amount: 123.45,
          enabled: true,
          mode: RoundOffMode.nearest,
          toValue: 1,
        ),
        123,
      );
    });

    test('nearest to 10', () {
      expect(
        applyTransactionRoundOff(
          amount: 124,
          enabled: true,
          mode: RoundOffMode.nearest,
          toValue: 10,
        ),
        120,
      );
    });

    test('disabled returns raw amount', () {
      expect(
        applyTransactionRoundOff(
          amount: 99.99,
          enabled: false,
          mode: RoundOffMode.nearest,
          toValue: 1,
        ),
        99.99,
      );
    });
  });
}
