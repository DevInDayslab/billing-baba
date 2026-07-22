import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('truncateTextByLength', () {
    test('returns short names unchanged', () {
      expect(truncateTextByLength('Acme Corp', 20), 'Acme Corp');
    });

    test('returns exactly 20 characters unchanged', () {
      const name = '12345678901234567890';
      expect(name.length, 20);
      expect(truncateTextByLength(name, 20), name);
    });

    test('truncates long names with ellipsis', () {
      const name = 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';
      expect(
        truncateTextByLength(name, 20),
        'eeeeeeeeeeeeeeeeeeee...',
      );
    });
  });

  group('AppTruncatedText', () {
    testWidgets('does not wrap short names in a tooltip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTruncatedText('Short Name'),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
      expect(find.text('Short Name'), findsOneWidget);
    });

    testWidgets('wraps truncated names in a tooltip', (tester) async {
      const longName = 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTruncatedText(longName),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      expect(find.text('eeeeeeeeeeeeeeeeeeee...'), findsOneWidget);
    });
  });
}
