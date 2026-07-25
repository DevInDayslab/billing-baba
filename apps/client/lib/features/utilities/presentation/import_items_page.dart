import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/import_items_page.dart';
import './mobile/import_items_page.dart';
import 'package:flutter/widgets.dart';

class ImportItemsPage extends StatelessWidget {
  const ImportItemsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopImportItemsPage(),
      mobile: const MobileImportItemsPage(),
    );
  }
}
