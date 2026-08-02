import 'package:billing_baba/features/purchases/presentation/mobile/add_payment_out_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddPaymentOutPage extends StatelessWidget {
  const AddPaymentOutPage({super.key, this.paymentId});

  final String? paymentId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const SizedBox.shrink(),
      mobile: MobileAddPaymentOutPage(paymentId: paymentId),
    );
  }
}
