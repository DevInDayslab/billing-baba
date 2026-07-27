import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/application/print_settings_provider.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobilePrintSettingsScreen extends ConsumerStatefulWidget {
  const MobilePrintSettingsScreen({super.key});

  @override
  ConsumerState<MobilePrintSettingsScreen> createState() =>
      _MobilePrintSettingsScreenState();
}

class _MobilePrintSettingsScreenState
    extends ConsumerState<MobilePrintSettingsScreen> {
  PrintSettings? _draft;
  bool _saving = false;

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(printSettingsProvider.notifier).save(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Print settings saved')),
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
    final settingsAsync = ref.watch(printSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'Print Settings',
        subtitle: 'Printer type, layout, and invoice content',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'Print Settings',
        subtitle: 'Printer type, layout, and invoice content',
        errorMessage: 'Failed to load print settings',
        onRetry: () => ref.invalidate(printSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) {
        _draft ??= settings;
        final draft = _draft!;

        return MobileSettingsDetailPage(
          title: 'Print Settings',
          subtitle: 'Printer type, layout, and invoice content',
          saveLabel: 'Save',
          onSave: _save,
          isSaving: _saving,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MobileCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    RadioListTile<PrinterType>(
                      title: const Text('Thermal printer'),
                      subtitle: const Text('58mm / 80mm receipt printers'),
                      value: PrinterType.thermal,
                      groupValue: draft.printerType,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _draft = draft.copyWith(printerType: value),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<PrinterType>(
                      title: const Text('Regular printer'),
                      subtitle: const Text('A4 / letter invoice printing'),
                      value: PrinterType.regular,
                      groupValue: draft.printerType,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _draft = draft.copyWith(printerType: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              MobileCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Print company logo'),
                  value: draft.printCompanyLogo,
                  onChanged: (value) => setState(
                    () => _draft = draft.copyWith(printCompanyLogo: value),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
