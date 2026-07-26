import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/business/presentation/desktop/business_list_page.dart';
import 'package:billing_baba/features/business/presentation/mobile/business_list_page.dart';
import 'package:flutter/widgets.dart';

class BusinessListPage extends StatelessWidget {
  const BusinessListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopBusinessListPage(),
      mobile: MobileBusinessListPage(),
    );
  }
}
