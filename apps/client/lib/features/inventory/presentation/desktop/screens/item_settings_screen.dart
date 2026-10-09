import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_settings/item_settings_vyapar_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopItemSettingsScreen extends ConsumerWidget {
  const DesktopItemSettingsScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(itemSettingsProvider);

    if (embedded) {
      return settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(OfflineUiMessages.messageFor(error)),
        ),
        data: (_) => const ItemSettingsVyaparPanel(),
      );
    }

    return _StandaloneItemSettingsShell(settingsAsync: settingsAsync);
  }
}

class _StandaloneItemSettingsShell extends ConsumerWidget {
  const _StandaloneItemSettingsShell({required this.settingsAsync});

  final AsyncValue<ItemSettings> settingsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(itemSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Item Settings',
          style: AppTypography.inter(
            fontSize: AppTypography.titleMediumSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: listPanelCardBorder),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (_) => const ItemSettingsVyaparPanel(),
      ),
    );
  }
}
