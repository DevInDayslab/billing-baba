import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/sync_share_page.dart';
import 'package:billing_baba/features/collaboration/presentation/mobile/sync_share_page.dart';
import 'package:flutter/widgets.dart';

class SyncSharePage extends StatelessWidget {
  const SyncSharePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopSyncSharePage(),
      mobile: MobileSyncSharePage(),
    );
  }
}
