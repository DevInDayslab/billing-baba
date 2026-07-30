import 'package:billing_baba/core/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_settings/item_settings_mobile_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileItemSettingsScreen extends ConsumerStatefulWidget {
  const MobileItemSettingsScreen({super.key});

  @override
  ConsumerState<MobileItemSettingsScreen> createState() =>
      _MobileItemSettingsScreenState();
}

class _MobileItemSettingsScreenState
    extends ConsumerState<MobileItemSettingsScreen> {
  ItemSettings? _draft;
  bool _saving = false;

  void _updateDraft(ItemSettingsUpdater updater) {
    final current = _draft;
    if (current == null) return;
    setState(() => _draft = updater(current));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(itemSettingsProvider.notifier).save(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item settings saved')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(itemSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'Item Settings',
        subtitle: 'Configure how items work across your business',
        isLoading: true,
        padding: EdgeInsets.zero,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'Item Settings',
        subtitle: 'Configure how items work across your business',
        errorMessage: 'Failed to load item settings',
        onRetry: () => ref.invalidate(itemSettingsProvider),
        padding: EdgeInsets.zero,
        body: const SizedBox.shrink(),
      ),
      data: (settings) {
        _draft ??= settings;

        return MobileSettingsDetailPage(
          title: 'Item Settings',
          subtitle: 'Configure how items work across your business',
          saveLabel: 'Save',
          onSave: _save,
          isSaving: _saving,
          padding: EdgeInsets.zero,
          body: ItemSettingsMobilePanel(
            settings: _draft!,
            onUpdate: _updateDraft,
          ),
        );
      },
    );
  }
}
