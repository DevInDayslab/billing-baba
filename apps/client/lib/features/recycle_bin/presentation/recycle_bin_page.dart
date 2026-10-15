import 'package:billing_baba/features/recycle_bin/presentation/desktop/desktop_recycle_bin_page.dart';
import 'package:billing_baba/features/recycle_bin/presentation/mobile/mobile_recycle_bin_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopRecycleBinPage(),
      mobile: MobileRecycleBinPage(),
    );
  }
}
