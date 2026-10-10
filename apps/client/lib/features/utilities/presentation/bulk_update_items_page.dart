import 'package:billing_baba/features/utilities/presentation/desktop/bulk_update_items_page.dart';
import 'package:billing_baba/features/utilities/presentation/mobile/bulk_update_items_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class BulkUpdateItemsPage extends StatelessWidget {
  const BulkUpdateItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopBulkUpdateItemsPage(),
      mobile: MobileBulkUpdateItemsPage(),
    );
  }
}
