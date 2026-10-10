import 'package:billing_baba/features/utilities/presentation/desktop/export_items_page.dart';
import 'package:billing_baba/features/utilities/presentation/mobile/export_items_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class ExportItemsPage extends StatelessWidget {
  const ExportItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopExportItemsPage(),
      mobile: MobileExportItemsPage(),
    );
  }
}
