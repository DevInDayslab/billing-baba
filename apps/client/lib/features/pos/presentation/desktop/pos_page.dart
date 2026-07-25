import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_session_provider.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_landing_content.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_page_title_bar.dart';
import 'package:billing_baba/features/pos/presentation/pos_sales_history_page.dart';
import 'package:billing_baba/features/pos/presentation/pos_terminal_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);

/// POS module entry: landing list/empty state, or full billing terminal.
class DesktopPosPage extends ConsumerWidget {
  const DesktopPosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(posSessionProvider);

    if (session.isTerminalOpen) {
      return const PosTerminalView();
    }

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PosPageTitleBar(
              onHistoryTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PosSalesHistoryPage(),
                  ),
                );
              },
              onSettingsTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: _cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: PosLandingContent(
                onStartSale: () =>
                    ref.read(posSessionProvider.notifier).openTerminal(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
