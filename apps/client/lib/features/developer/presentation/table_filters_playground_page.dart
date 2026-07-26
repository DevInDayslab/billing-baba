import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/developer/presentation/desktop/table_filters_playground_page.dart';
import 'package:billing_baba/features/developer/presentation/mobile/table_filters_playground_page.dart';
import 'package:flutter/widgets.dart';

class TableFiltersPlaygroundPage extends StatelessWidget {
  const TableFiltersPlaygroundPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopTableFiltersPlaygroundPage(),
      mobile: MobileTableFiltersPlaygroundPage(),
    );
  }
}
