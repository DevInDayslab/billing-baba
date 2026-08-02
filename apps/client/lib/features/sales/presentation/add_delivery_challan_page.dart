import 'package:billing_baba/features/sales/presentation/desktop/add_delivery_challan_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_delivery_challan_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
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
      desktop: DesktopAddDeliveryChallanPage(
        challanId: challanId,
        duplicateFromId: duplicateFromId,
      ),
      mobile: MobileAddDeliveryChallanPage(
        challanId: challanId,
        duplicateFromId: duplicateFromId,
      ),
    );
  }
}
