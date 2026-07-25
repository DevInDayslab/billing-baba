import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/diagnostics_page.dart';
import './mobile/diagnostics_page.dart';
import 'package:flutter/widgets.dart';

class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopDiagnosticsPage(),
      mobile: const MobileDiagnosticsPage(),
    );
  }
}
