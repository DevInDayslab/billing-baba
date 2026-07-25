import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/payment_out_page.dart';
import './mobile/payment_out_page.dart';
import 'package:flutter/widgets.dart';

class PaymentOutPage extends StatelessWidget {
  const PaymentOutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPaymentOutPage(),
      mobile: const MobilePaymentOutPage(),
    );
  }
}
