import 'package:billing_baba/features/sales/presentation/desktop/payment_in_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/payment_in_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class PaymentInPage extends StatelessWidget {
  const PaymentInPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPaymentInPage(),
      mobile: MobilePaymentInPage(),
    );
  }
}
