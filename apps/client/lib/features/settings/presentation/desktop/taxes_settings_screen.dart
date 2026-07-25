import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/commerce_settings_model.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopTaxesSettingsScreen extends ConsumerStatefulWidget {
  const DesktopTaxesSettingsScreen({super.key});

  @override
  ConsumerState<DesktopTaxesSettingsScreen> createState() =>
      _TaxesSettingsScreenState();
}

class _TaxesSettingsScreenState extends ConsumerState<DesktopTaxesSettingsScreen> {
  final _tierControllers = <String, TextEditingController>{};
  String _defaultTaxLabel = 'None';
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _tierControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncDraft(CommerceSettingsModel settings) {
    for (final tier in PriceTier.all) {
      final apiTier = PriceTier.toApiTier(tier);
      final label = settings.pricingTierLabels[apiTier] ??
          PriceTier.labelFor(tier);
      _tierControllers.putIfAbsent(
        tier,
        () => TextEditingController(text: label),
      )..text = label;
    }
    final defaultTax = settings.defaultInvoiceTaxPercent;
    _defaultTaxLabel = ItemTaxRate.labelForPercent(defaultTax);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final tierLabels = <String, String>{};
      for (final tier in PriceTier.all) {
        final label = _tierControllers[tier]?.text.trim() ?? '';
        if (label.isNotEmpty) {
          tierLabels[PriceTier.toApiTier(tier)] = label;
        }
      }
      final defaultTax = ItemTaxRate.parsePercent(_defaultTaxLabel);
      await ref.read(commerceSettingsProvider.notifier).save(
            pricingTierLabels: tierLabels,
            defaultInvoiceTaxRate: defaultTax,
            clearDefaultInvoiceTaxRate: defaultTax == null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tax settings saved')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save tax settings: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(commerceSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Taxes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load: $error')),
        data: (settings) {
          _syncDraft(settings);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Text(
                'Tier pricing names',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customize how tier prices appear across items, parties, and invoices.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FormGrid(
                cells: [
                  for (final tier in PriceTier.all)
                    FormGridCell(
                      span: 6,
                      child: AppFormField(
                        label: '${PriceTier.labelFor(tier)} tier label',
                        child: TextField(
                          controller: _tierControllers[tier],
                          decoration: const InputDecoration(
                            hintText: 'Display name',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppFormField(
                label: 'Default invoice GST rate',
                child: SaleGenericSelectDropdown(
                  value: _defaultTaxLabel,
                  options: ItemTaxRate.options,
                  onSelected: (value) => setState(() => _defaultTaxLabel = value),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Used for new invoice lines when an item has no default GST rate. '
                'The most recently selected line GST rate is remembered per business.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          );
        },
      ),
    );
  }
}
