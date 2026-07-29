import 'package:billing_baba/features/sales/presentation/desktop/add_sale_fa_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_sale_fa_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddSaleFaPage extends StatelessWidget {
  const AddSaleFaPage({
    super.key,
    this.batchId,
  });

  final String? batchId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddSaleFaPage(batchId: batchId),
      mobile: MobileAddSaleFaPage(batchId: batchId),
    );
  }
}
