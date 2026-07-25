import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/presentation/desktop/pos_return_page.dart';
import 'package:billing_baba/features/pos/presentation/mobile/pos_return_page.dart';
import 'package:flutter/widgets.dart';

class PosReturnPage extends StatelessWidget {
  const PosReturnPage({
    required this.originalSale, super.key,
  });

  final PosSale originalSale;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopPosReturnPage(originalSale: originalSale),
      mobile: MobilePosReturnPage(originalSale: originalSale),
    );
  }
}
