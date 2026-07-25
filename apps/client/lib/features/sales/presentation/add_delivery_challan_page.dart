import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_delivery_challan_page.dart';
import './mobile/add_delivery_challan_page.dart';
import 'package:flutter/widgets.dart';

class AddDeliveryChallanPage extends StatelessWidget {
  const AddDeliveryChallanPage({
    super.key,
    this.challanId,
    this.duplicateFromId,
  });

  final String? challanId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddDeliveryChallanPage(challanId: challanId, duplicateFromId: duplicateFromId),
      mobile: MobileAddDeliveryChallanPage(challanId: challanId, duplicateFromId: duplicateFromId),
    );
  }
}
