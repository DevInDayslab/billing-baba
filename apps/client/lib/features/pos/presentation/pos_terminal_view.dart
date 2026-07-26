import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/pos/presentation/desktop/pos_terminal_view.dart';
import 'package:billing_baba/features/pos/presentation/mobile/pos_terminal_view.dart';
import 'package:flutter/widgets.dart';

class PosTerminalView extends StatelessWidget {
  const PosTerminalView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPosTerminalView(),
      mobile: MobilePosTerminalView(),
    );
  }
}
