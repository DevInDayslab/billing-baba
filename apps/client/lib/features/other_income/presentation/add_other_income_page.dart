import 'package:billing_baba/features/other_income/presentation/desktop/add_other_income_page.dart';
import 'package:billing_baba/features/other_income/presentation/mobile/add_other_income_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddOtherIncomePage extends StatelessWidget {
  const AddOtherIncomePage({
    super.key,
    this.incomeId,
  });

  final String? incomeId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddOtherIncomePage(incomeId: incomeId),
      mobile: MobileAddOtherIncomePage(incomeId: incomeId),
    );
  }
}
