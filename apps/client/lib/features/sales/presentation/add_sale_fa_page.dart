import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_sale_fa_page.dart';
import './mobile/add_sale_fa_page.dart';
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
