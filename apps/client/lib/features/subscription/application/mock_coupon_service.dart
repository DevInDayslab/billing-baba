/// Frontend-only coupon validation for the subscription checkout flow.
class MockCouponService {
  const MockCouponService();

  static const _percentCoupons = <String, double>{
    'SAVE10': 0.10,
    'WELCOME15': 0.15,
  };

  static const _flatCoupons = <String, double>{
    'FLAT500': 500,
    'FLAT1000': 1000,
  };

  MockCouponValidation validate({
    required String code,
    required double taxableBase,
  }) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return const MockCouponValidation.invalid('Enter a coupon code.');
    }

    final percentRate = _percentCoupons[normalized];
    if (percentRate != null) {
      return MockCouponValidation.valid(
        code: normalized,
        discountOnTaxable: taxableBase * percentRate,
      );
    }

    final flatAmount = _flatCoupons[normalized];
    if (flatAmount != null) {
      return MockCouponValidation.valid(
        code: normalized,
        discountOnTaxable: flatAmount,
      );
    }

    return const MockCouponValidation.invalid('Invalid coupon code.');
  }
}

sealed class MockCouponValidation {
  const MockCouponValidation();

  const factory MockCouponValidation.valid({
    required String code,
    required double discountOnTaxable,
  }) = MockCouponValid;

  const factory MockCouponValidation.invalid(String message) =
      MockCouponInvalid;
}

class MockCouponValid extends MockCouponValidation {
  const MockCouponValid({
    required this.code,
    required this.discountOnTaxable,
  });

  final String code;
  final double discountOnTaxable;
}

class MockCouponInvalid extends MockCouponValidation {
  const MockCouponInvalid(this.message);

  final String message;
}
