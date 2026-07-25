import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_purchase_page.dart';
import './mobile/add_purchase_page.dart';
import 'package:flutter/widgets.dart';

class AddPurchasePage extends StatelessWidget {
  const AddPurchasePage({
    super.key,
    this.billId,
  });

  final String? billId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddPurchasePage(billId: billId),
      mobile: MobileAddPurchasePage(billId: billId),
    );
  }
}
