/// ISO currency codes supported for business profile / general settings.
abstract final class BusinessCurrencyOptions {
  static const codes = ['INR', 'USD', 'EUR', 'GBP', 'AED'];

  static String labelFor(String code) => switch (code) {
    'INR' => 'INR (₹)',
    'USD' => r'USD ($)',
    'EUR' => 'EUR (€)',
    'GBP' => 'GBP (£)',
    'AED' => 'AED',
    _ => code,
  };

  static String symbolFor(String code) => switch (code) {
    'INR' => '₹',
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    'AED' => 'AED ',
    _ => '',
  };
}
