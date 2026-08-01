import 'package:billing_baba/features/sales/presentation/mobile/add_payment_in_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddPaymentInPage extends StatelessWidget {
  const AddPaymentInPage({super.key, this.paymentId});

  final String? paymentId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const SizedBox.shrink(),
      mobile: MobileAddPaymentInPage(paymentId: paymentId),
    );
  }
}
