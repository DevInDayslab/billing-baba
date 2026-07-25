import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/business_list_page.dart';
import './mobile/business_list_page.dart';
import 'package:flutter/widgets.dart';

class BusinessListPage extends StatelessWidget {
  const BusinessListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopBusinessListPage(),
      mobile: const MobileBusinessListPage(),
    );
  }
}
