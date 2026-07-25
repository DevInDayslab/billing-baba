import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/payment_in_page.dart';
import './mobile/payment_in_page.dart';
import 'package:flutter/widgets.dart';

class PaymentInPage extends StatelessWidget {
  const PaymentInPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPaymentInPage(),
      mobile: const MobilePaymentInPage(),
    );
  }
}
