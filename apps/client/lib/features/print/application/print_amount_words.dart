/// Converts a numeric amount to Indian English words for invoices.
abstract final class PrintAmountWords {
  static const _ones = <String>[
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const _tens = <String>[
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static String fromAmount(String amount) {
    final value = double.tryParse(amount) ?? 0;
    return fromDouble(value);
  }

  static String fromDouble(double amount) {
    if (amount == 0) return 'Zero Rupees Only';

    final rupees = amount.floor();
    final paise = ((amount - rupees) * 100).round();

    final rupeeWords = _convertWhole(rupees);
    final buffer = StringBuffer();

    if (rupeeWords.isNotEmpty) {
      buffer.write('$rupeeWords Rupee${rupees == 1 ? '' : 's'}');
    }

    if (paise > 0) {
      if (buffer.isNotEmpty) buffer.write(' and ');
      final paiseWords = _convertWhole(paise);
      buffer.write('$paiseWords Paise');
    }

    buffer.write(' Only');
    return buffer.toString();
  }

  static String _convertWhole(int number) {
    if (number == 0) return '';
    if (number < 20) return _ones[number];
    if (number < 100) {
      final ten = number ~/ 10;
      final one = number % 10;
      return '${_tens[ten]}${one > 0 ? ' ${_ones[one]}' : ''}'.trim();
    }
    if (number < 1000) {
      final hundred = number ~/ 100;
      final rest = number % 100;
      return '${_ones[hundred]} Hundred${rest > 0 ? ' ${_convertWhole(rest)}' : ''}'
          .trim();
    }
    if (number < 100000) {
      final thousand = number ~/ 1000;
      final rest = number % 1000;
      return '${_convertWhole(thousand)} Thousand${rest > 0 ? ' ${_convertWhole(rest)}' : ''}'
          .trim();
    }
    if (number < 10000000) {
      final lakh = number ~/ 100000;
      final rest = number % 100000;
      return '${_convertWhole(lakh)} Lakh${rest > 0 ? ' ${_convertWhole(rest)}' : ''}'
          .trim();
    }

    final crore = number ~/ 10000000;
    final rest = number % 10000000;
    return '${_convertWhole(crore)} Crore${rest > 0 ? ' ${_convertWhole(rest)}' : ''}'
        .trim();
  }
}
