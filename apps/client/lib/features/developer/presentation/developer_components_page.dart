import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/developer/presentation/desktop/developer_components_page.dart';
import 'package:billing_baba/features/developer/presentation/mobile/developer_components_page.dart';
import 'package:flutter/widgets.dart';

export 'package:billing_baba/features/developer/presentation/desktop/developer_components_page.dart'
    show DeveloperComponentPlaceholderPage, buildDeveloperComponentPage;

class DeveloperComponentsPage extends StatelessWidget {
  const DeveloperComponentsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopDeveloperComponentsPage(),
      mobile: MobileDeveloperComponentsPage(),
    );
  }
}
