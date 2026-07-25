import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/pos/presentation/desktop/pos_page.dart';
import 'package:billing_baba/features/pos/presentation/mobile/pos_page.dart';
import 'package:flutter/widgets.dart';

class PosPage extends StatelessWidget {
  const PosPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPosPage(),
      mobile: MobilePosPage(),
    );
  }
}
