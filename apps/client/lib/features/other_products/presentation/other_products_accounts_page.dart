import 'package:billing_baba/features/other_products/presentation/desktop/desktop_other_products_accounts_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class OtherProductsAccountsPage extends StatelessWidget {
  const OtherProductsAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopOtherProductsAccountsPage(),
      mobile: DesktopOtherProductsAccountsPage(),
    );
  }
}
