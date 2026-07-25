import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/barcode_generator_page.dart';
import './mobile/barcode_generator_page.dart';
import 'package:flutter/widgets.dart';

class BarcodeGeneratorPage extends StatelessWidget {
  const BarcodeGeneratorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopBarcodeGeneratorPage(),
      mobile: const MobileBarcodeGeneratorPage(),
    );
  }
}
