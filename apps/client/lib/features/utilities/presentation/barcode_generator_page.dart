import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/barcode_generator_page.dart';
import 'package:billing_baba/features/utilities/presentation/mobile/barcode_generator_page.dart';
import 'package:flutter/widgets.dart';

class BarcodeGeneratorPage extends StatelessWidget {
  const BarcodeGeneratorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopBarcodeGeneratorPage(),
      mobile: MobileBarcodeGeneratorPage(),
    );
  }
}
