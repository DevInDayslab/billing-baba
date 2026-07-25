import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/import_items_page.dart';
import 'package:billing_baba/features/utilities/presentation/mobile/import_items_page.dart';
import 'package:flutter/widgets.dart';

class ImportItemsPage extends StatelessWidget {
  const ImportItemsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopImportItemsPage(),
      mobile: MobileImportItemsPage(),
    );
  }
}
