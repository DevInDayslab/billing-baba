import 'package:billing_baba/features/sales/presentation/mobile/add_payment_in_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddPaymentInPage extends StatelessWidget {
  const AddPaymentInPage({
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
      mobile: MobileAddPaymentInPage(
        paymentId: paymentId,
        initialPartyId: initialPartyId,
        initialPartyName: initialPartyName,
      ),
    );
  }
}
