import 'package:billing_baba/features/purchases/presentation/desktop/payment_out_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/payment_out_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class PaymentOutPage extends StatelessWidget {
  const PaymentOutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPaymentOutPage(),
      mobile: MobilePaymentOutPage(),
    );
  }
}
