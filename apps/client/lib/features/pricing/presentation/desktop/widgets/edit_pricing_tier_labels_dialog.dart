import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a dialog to rename the four pricing tiers for the current business.
Future<bool> showEditPricingTierLabelsDialog(BuildContext context) async {
  final saved = await showFormDialog<bool>(
    context: context,
    size: FormDialogSize.compact,
    child: const EditPricingTierLabelsDialog(),
  );
  return saved ?? false;
}

class EditPricingTierLabelsDialog extends ConsumerStatefulWidget {
  const EditPricingTierLabelsDialog({super.key});

  @override
  ConsumerState<EditPricingTierLabelsDialog> createState() =>
      _EditPricingTierLabelsDialogState();
}

class _EditPricingTierLabelsDialogState
    extends ConsumerState<EditPricingTierLabelsDialog> {
  final _controllers = <String, TextEditingController>{};
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(Map<String, String> labels) {
    for (final tier in PriceTier.all) {
      final apiTier = PriceTier.toApiTier(tier);
      final label = labels[apiTier] ?? PriceTier.labelFor(tier);
      final controller = _controllers.putIfAbsent(
        tier,
        () => TextEditingController(text: label),
      );
      controller.text = label;
    }
  }

  Future<void> _save() async {
    final tierLabels = <String, String>{};
    for (final tier in PriceTier.all) {
      final label = _controllers[tier]?.text.trim() ?? '';
      if (label.isEmpty) {
        setState(
          () => _errorMessage =
              'All tier names are required (${PriceTier.labelFor(tier)} slot).',
        );
        return;
      }
      tierLabels[PriceTier.toApiTier(tier)] = label;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await ref.read(commerceSettingsProvider.notifier).save(
            pricingTierLabels: tierLabels,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = 'Could not save tier names. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(pricingTierLabelsProvider);
    _ensureControllers(labels);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Customize Tier Names',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed:
                      _saving ? null : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'These names appear when assigning a default price tier to parties '
              'and when setting tier-based item prices.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            FormGrid(
              cells: [
                for (final tier in PriceTier.all)
                  FormGridCell(
                    span: 6,
                    child: AppFormField(
                      label: '${PriceTier.labelFor(tier)} slot',
                      child: TextField(
                        controller: _controllers[tier],
                        enabled: !_saving,
                        style: saleFieldTextStyle,
                        decoration: buildSaleFieldDecoration(
                          hint: PriceTier.labelFor(tier),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: saleFieldErrorColor),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Tier Names'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
