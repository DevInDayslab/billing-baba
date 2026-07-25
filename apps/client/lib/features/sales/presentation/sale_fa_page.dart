import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/sale_fa_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/sale_fa_page.dart';
import 'package:flutter/widgets.dart';

class SaleFaPage extends StatelessWidget {
  const SaleFaPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSaleFaPage(),
      mobile: MobileSaleFaPage(),
    );
  }
}
