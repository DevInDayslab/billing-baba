import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_items_barcode_screen.dart';
import './mobile/add_items_barcode_screen.dart';
import 'package:flutter/widgets.dart';

class AddItemsBarcodeScreen extends StatelessWidget {
  const AddItemsBarcodeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopAddItemsBarcodeScreen(),
      mobile: const MobileAddItemsBarcodeScreen(),
    );
  }
}
