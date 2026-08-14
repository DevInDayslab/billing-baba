import 'package:billing_baba/features/parties/utils/party_search_match.dart';
import 'package:billing_baba/shared/utils/clear_zero_decimal_on_focus.dart';
import 'package:billing_baba/shared/utils/gstin_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PartySearchMatch', () {
    test('matches keywords in any order', () {
      const fields = ['Rahul Kumar Sharma'];
      expect(
        PartySearchMatch.matchesFields(
          queryWords: PartySearchMatch.queryWords('sharma rahul'),
          fields: fields,
        ),
        isTrue,
      );
      expect(
        PartySearchMatch.matchesFields(
          queryWords: PartySearchMatch.queryWords('kumar'),
          fields: fields,
        ),
        isTrue,
      );
      expect(
        PartySearchMatch.matchesFields(
          queryWords: PartySearchMatch.queryWords('anita'),
          fields: fields,
        ),
        isFalse,
      );
    });
  });

  group('ClearZeroDecimalOnFocus', () {
    test('treats 0.00 as a clearable placeholder', () {
      expect(ClearZeroDecimalOnFocus.isZeroDecimal('0.00'), isTrue);
      expect(ClearZeroDecimalOnFocus.isZeroDecimal('0'), isTrue);
      expect(ClearZeroDecimalOnFocus.isZeroDecimal('150.00'), isFalse);
      expect(ClearZeroDecimalOnFocus.isZeroDecimal('-20.00'), isFalse);
    });
  });

  group('GstinValidator', () {
    test('normalizes lowercase and requires 15 alphanumeric characters', () {
      expect(GstinValidator.normalize('  27abcde1234f1z5 '), '27ABCDE1234F1Z5');
      expect(
        GstinValidator.validationError('27ABCDE1234F1Z'),
        'GSTIN must contain exactly 15 characters',
      );
    });
  });
}
