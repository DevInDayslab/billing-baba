import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/sale_fa_page.dart';
import './mobile/sale_fa_page.dart';
import 'package:flutter/widgets.dart';

class SaleFaPage extends StatelessWidget {
  const SaleFaPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopSaleFaPage(),
      mobile: const MobileSaleFaPage(),
    );
  }
}
