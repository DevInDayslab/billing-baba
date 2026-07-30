import 'package:billing_baba/features/inventory/presentation/desktop/add_items_barcode_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/add_items_barcode_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddItemsBarcodeScreen extends StatelessWidget {
  const AddItemsBarcodeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopAddItemsBarcodeScreen(),
      mobile: MobileAddItemsBarcodeScreen(),
    );
  }
}
