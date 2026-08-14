import 'package:billing_baba/features/purchases/presentation/mobile/add_payment_out_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddPaymentOutPage extends StatelessWidget {
  const AddPaymentOutPage({
    super.key,
    this.paymentId,
    this.initialPartyId,
    this.initialPartyName,
  });

  final String? paymentId;
  final String? initialPartyId;
  final String? initialPartyName;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const SizedBox.shrink(),
      mobile: MobileAddPaymentOutPage(
        paymentId: paymentId,
        initialPartyId: initialPartyId,
        initialPartyName: initialPartyName,
      ),
    );
  }
}
