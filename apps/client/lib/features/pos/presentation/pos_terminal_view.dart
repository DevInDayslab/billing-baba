import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/pos_terminal_view.dart';
import './mobile/pos_terminal_view.dart';
import 'package:flutter/widgets.dart';

class PosTerminalView extends StatelessWidget {
  const PosTerminalView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPosTerminalView(),
      mobile: const MobilePosTerminalView(),
    );
  }
}
