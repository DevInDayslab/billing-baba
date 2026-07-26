import 'package:billing_baba/shared/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:billing_baba/features/settings/application/whatsapp_settings_provider.dart';
import 'package:billing_baba/features/settings/presentation/mobile/widgets/mobile_settings_placeholder_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileWhatsAppSettingsScreen extends ConsumerStatefulWidget {
  const MobileWhatsAppSettingsScreen({super.key});

  @override
  ConsumerState<MobileWhatsAppSettingsScreen> createState() =>
      _MobileWhatsAppSettingsScreenState();
}

class _MobileWhatsAppSettingsScreenState
    extends ConsumerState<MobileWhatsAppSettingsScreen> {
  bool? _enabled;
  bool _saving = false;

  Future<void> _save() async {
    final enabled = _enabled;
    if (enabled == null || _saving) return;

    setState(() => _saving = true);
    try {
      final current = await ref.read(whatsAppSettingsProvider.future);
      await ref
          .read(whatsAppSettingsProvider.notifier)
          .save(current.copyWith(enabled: enabled));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp settings saved')),
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
    final settingsAsync = ref.watch(whatsAppSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'WhatsApp',
        subtitle: 'Enable messaging and test delivery',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'WhatsApp',
        subtitle: 'Enable messaging and test delivery',
        errorMessage: 'Failed to load WhatsApp settings',
        onRetry: () => ref.invalidate(whatsAppSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) {
        _enabled ??= settings.enabled;

        return MobileSettingsDetailPage(
          title: 'WhatsApp',
          subtitle: 'Enable messaging and test delivery',
          saveLabel: 'Save',
          onSave: _save,
          isSaving: _saving,
          body: MobileSettingsSwitchTile(
            title: 'Enable WhatsApp Messaging',
            subtitle: 'Send invoices and payment reminders via WhatsApp',
            value: _enabled!,
            onChanged: (value) => setState(() => _enabled = value),
          ),
        );
      },
    );
  }
}
