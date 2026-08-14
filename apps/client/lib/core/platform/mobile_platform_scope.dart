import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart'
    show AdaptivePage;
import 'package:flutter/widgets.dart';

/// Guards mobile-only UI from being mounted on desktop platforms.
///
/// Desktop builds use a separate shell and page implementations selected via
/// [AdaptivePage] in `core/widgets/adaptive_page.dart`.
class MobilePlatformScope extends StatelessWidget {
  const MobilePlatformScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(
      AppPlatform.current.isMobile,
      'MobilePlatformScope must only be used on mobile platforms.',
    );
    return child;
  }
}
