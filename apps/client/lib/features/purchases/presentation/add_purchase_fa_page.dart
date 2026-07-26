import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/add_purchase_fa_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/add_purchase_fa_page.dart';
import 'package:flutter/widgets.dart';

class AddPurchaseFaPage extends StatelessWidget {
  const AddPurchaseFaPage({
    super.key,
    this.batchId,
  });

  final String? batchId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddPurchaseFaPage(batchId: batchId),
      mobile: MobileAddPurchaseFaPage(batchId: batchId),
    );
  }
}
