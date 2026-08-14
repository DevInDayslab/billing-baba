import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpeningBalanceDirection', () {
    test('signedOpeningBalanceString stores receive as positive', () {
      expect(
        PartyModel.signedOpeningBalanceString(
          magnitude: '500.00',
          direction: OpeningBalanceDirection.toReceive,
        ),
        '500.00',
      );
    });

    test('signedOpeningBalanceString stores pay as negative', () {
      expect(
        PartyModel.signedOpeningBalanceString(
          magnitude: '500.00',
          direction: OpeningBalanceDirection.toPay,
        ),
        '-500.00',
      );
    });

    test('signedOpeningBalanceString zero ignores direction', () {
      expect(
        PartyModel.signedOpeningBalanceString(
          magnitude: '0.00',
          direction: OpeningBalanceDirection.toPay,
        ),
        '0',
      );
    });

    test('openingBalanceDirection derives direction from sign', () {
      expect(
        PartyModel.openingBalanceDirection(250),
        OpeningBalanceDirection.toReceive,
      );
      expect(
        PartyModel.openingBalanceDirection(-250),
        OpeningBalanceDirection.toPay,
      );
      expect(
        PartyModel.openingBalanceDirection(0),
        OpeningBalanceDirection.toReceive,
      );
    });

    test('displayOpeningBalance includes direction for non-zero amounts', () {
      expect(
        PartyModel.displayOpeningBalance(250),
        contains('To Receive'),
      );
      expect(
        PartyModel.displayOpeningBalance(-250),
        contains('To Pay'),
      );
    });

    test('formatDecimalInput always shows magnitude', () {
      expect(PartyModel.formatDecimalInput(-750), '750.00');
      expect(PartyModel.formatDecimalInput(750), '750.00');
    });
  });
}
