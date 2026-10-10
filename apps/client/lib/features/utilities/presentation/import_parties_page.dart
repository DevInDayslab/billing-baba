import 'package:billing_baba/features/utilities/presentation/desktop/import_parties_page.dart';
import 'package:billing_baba/features/utilities/presentation/mobile/import_parties_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class ImportPartiesPage extends StatelessWidget {
  const ImportPartiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopImportPartiesPage(),
      mobile: MobileImportPartiesPage(),
    );
  }
}
