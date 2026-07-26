import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/developer/presentation/desktop/diagnostics_page.dart';
import 'package:billing_baba/features/developer/presentation/mobile/diagnostics_page.dart';
import 'package:flutter/widgets.dart';

class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopDiagnosticsPage(),
      mobile: MobileDiagnosticsPage(),
    );
  }
}
