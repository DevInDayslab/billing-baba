import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSaleTime', () {
    test('parses 12-hour times with AM/PM', () {
      expect(
        parseSaleTime('7:30 PM'),
        const TimeOfDay(hour: 19, minute: 30),
      );
      expect(
        parseSaleTime('7pm'),
        const TimeOfDay(hour: 19, minute: 0),
      );
      expect(
        parseSaleTime('12:00 AM'),
        const TimeOfDay(hour: 0, minute: 0),
      );
      expect(
        parseSaleTime('12 PM'),
        const TimeOfDay(hour: 12, minute: 0),
      );
    });

    test('parses 24-hour and dotted times', () {
      expect(
        parseSaleTime('19:30'),
        const TimeOfDay(hour: 19, minute: 30),
      );
      expect(
        parseSaleTime('7.30 pm'),
        const TimeOfDay(hour: 19, minute: 30),
      );
    });

    test('returns null for empty or invalid input', () {
      expect(parseSaleTime(''), isNull);
      expect(parseSaleTime('abc'), isNull);
      expect(parseSaleTime('25:00'), isNull);
      expect(parseSaleTime('7:99 PM'), isNull);
    });
  });
}
