import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/pos_page.dart';
import './mobile/pos_page.dart';
import 'package:flutter/widgets.dart';

class PosPage extends StatelessWidget {
  const PosPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPosPage(),
      mobile: const MobilePosPage(),
    );
  }
}
