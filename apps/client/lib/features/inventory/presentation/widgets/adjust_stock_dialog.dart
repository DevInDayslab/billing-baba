import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAdjustStockDialog(
  BuildContext context, {
  required InventoryItem item,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AdjustStockDialog(item: item),
    ),
  );
}

class AdjustStockDialog extends ConsumerStatefulWidget {
  const AdjustStockDialog({required this.item, super.key});

  final InventoryItem item;

  @override
  ConsumerState<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends ConsumerState<AdjustStockDialog> {
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  String? _godownId;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(4);
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final delta = double.tryParse(_quantityController.text.trim());
    if (delta == null || delta == 0) {
      setState(() => _errorMessage = 'Enter a non-zero quantity adjustment.');
      return;
    }

    if (_godownId == null) {
      setState(() => _errorMessage = 'Select a godown.');
      return;
    }

    final costText = _costController.text.trim();
    final cost = costText.isEmpty ? null : double.tryParse(costText);
    if (delta > 0 && cost == null) {
      setState(
        () => _errorMessage =
            'Cost per unit is required for positive adjustments.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.createMovement(
        CreateMovementRequest(
          itemId: widget.item.id,
          godownId: _godownId!,
          movementType: 'adjustment',
          quantityDelta: _formatDecimal(delta),
          costPerUnit: cost != null ? _formatDecimal(cost) : null,
        ),
      );

      await ref
          .read(inventoryItemsProvider.notifier)
          .refreshAfterStockAdjustment(widget.item.id);

      if (!mounted) return;
      Navigator.of(context).pop();
    } on InventoryException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = InventoryErrorMapper.messageFor(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);
    final godowns = godownsAsync.value ?? [];
    _godownId ??= godowns.isNotEmpty ? godowns.first.id : null;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Material(
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
                  Expanded(
                    child: Text(
                      'Adjust Stock — ${widget.item.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Quantity delta (+/-)', style: saleFieldLabelStyle),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: buildSaleFieldDecoration(hint: 'e.g., -5 or 10'),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Godown', style: saleFieldLabelStyle),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _godownId,
                items: godowns
                    .map(
                      (godown) => DropdownMenuItem(
                        value: godown.id,
                        child: Text(godown.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _godownId = value),
                decoration: buildSaleFieldDecoration(hint: 'Select godown'),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Cost per unit (for +qty)',
                style: saleFieldLabelStyle,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: buildSaleFieldDecoration(
                  hint: 'Optional for reductions',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: saleFieldErrorColor,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: inventoryButtonHeight,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: inventoryNegativeColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Apply Adjustment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
