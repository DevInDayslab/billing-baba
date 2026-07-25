import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/table_filters_playground_page.dart';
import './mobile/table_filters_playground_page.dart';
import 'package:flutter/widgets.dart';

class TableFiltersPlaygroundPage extends StatelessWidget {
  const TableFiltersPlaygroundPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopTableFiltersPlaygroundPage(),
      mobile: const MobileTableFiltersPlaygroundPage(),
    );
  }
}
