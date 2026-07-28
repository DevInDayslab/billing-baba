import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_settings_tiles.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Editor for sale invoice terms and conditions text.
class SaleInvoiceTermsSettingsPage extends ConsumerStatefulWidget {
  const SaleInvoiceTermsSettingsPage({super.key});

  @override
  ConsumerState<SaleInvoiceTermsSettingsPage> createState() =>
      _SaleInvoiceTermsSettingsPageState();
}

class _SaleInvoiceTermsSettingsPageState
    extends ConsumerState<SaleInvoiceTermsSettingsPage> {
  late final TextEditingController _controller;
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    await ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(
      (settings) => settings.copyWith(
        termsAndConditionsText: text,
        termsAndConditionsEnabled: text.isNotEmpty,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(saleInvoiceSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'Set Terms & Conditions',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'Set Terms & Conditions',
        errorMessage: 'Failed to load settings',
        onRetry: () => ref.invalidate(saleInvoiceSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) {
        if (!_initialized) {
          _controller = TextEditingController(
            text: settings.termsAndConditionsText,
          );
          _initialized = true;
        }

        return MobileSettingsDetailPage(
          title: 'Set Terms & Conditions',
          subtitle: 'Shown on sale invoices when enabled',
          saveLabel: 'Save',
          onSave: _save,
          body: TextField(
            controller: _controller,
            minLines: 6,
            maxLines: 12,
            decoration: InputDecoration(
              hintText: 'Enter terms and conditions...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: AppRadius.lgBorder,
                borderSide: const BorderSide(color: Color(0xFFE8EAED)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lgBorder,
                borderSide: const BorderSide(color: Color(0xFFE8EAED)),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Passcode protection settings for editing/deleting sale invoices.
class SaleInvoicePasscodeSettingsPage extends ConsumerStatefulWidget {
  const SaleInvoicePasscodeSettingsPage({super.key});

  @override
  ConsumerState<SaleInvoicePasscodeSettingsPage> createState() =>
      _SaleInvoicePasscodeSettingsPageState();
}

class _SaleInvoicePasscodeSettingsPageState
    extends ConsumerState<SaleInvoicePasscodeSettingsPage> {
  late final TextEditingController _controller;
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(saleInvoiceSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'Passcode for Edit/Delete',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'Passcode for Edit/Delete',
        errorMessage: 'Failed to load settings',
        onRetry: () => ref.invalidate(saleInvoiceSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) {
        if (!_initialized) {
          _controller = TextEditingController(text: settings.passcode);
          _initialized = true;
        } else if (_controller.text != settings.passcode &&
            !FocusScope.of(context).hasFocus) {
          _controller.text = settings.passcode;
        }

        return MobileSettingsDetailPage(
          title: 'Passcode for Edit/Delete',
          subtitle: 'Require a passcode before editing or deleting invoices',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsSection(
                title: 'Security',
                children: [
                  SwitchTile(
                    title: 'Enable Passcode',
                    value: settings.passcodeForEditDeleteEnabled,
                    onChanged: (value) => ref
                        .read(saleInvoiceSettingsProvider.notifier)
                        .updateSettings(
                          (s) =>
                              s.copyWith(passcodeForEditDeleteEnabled: value),
                        ),
                  ),
                ],
              ),
              if (settings.passcodeForEditDeleteEnabled) ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    labelText: '4-digit passcode',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.lgBorder,
                    ),
                  ),
                  onChanged: (value) => ref
                      .read(saleInvoiceSettingsProvider.notifier)
                      .updateSettings((s) => s.copyWith(passcode: value)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Additional custom fields for sale invoices.
class SaleInvoiceAdditionalFieldsPage extends ConsumerWidget {
  const SaleInvoiceAdditionalFieldsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(saleInvoiceSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'Additional Fields',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'Additional Fields',
        errorMessage: 'Failed to load settings',
        onRetry: () => ref.invalidate(saleInvoiceSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) => MobileSettingsDetailPage(
        title: 'Additional Fields',
        subtitle:
            'Add extra fields to the sale invoice like License Number, PAN, dates and more.',
        body: SettingsSection(
          title: 'Fields',
          children: [
            SwitchTile(
              title: 'Enable Additional Fields',
              subtitle:
                  'Shows optional fields on the sale form when creating invoices.',
              value: settings.additionalFieldsEnabled,
              onChanged: (value) => ref
                  .read(saleInvoiceSettingsProvider.notifier)
                  .updateSettings((s) => s.copyWith(additionalFieldsEnabled: value)),
            ),
          ],
        ),
      ),
    );
  }
}
