import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showEditItemLocationDialog(
  BuildContext context, {
  required String itemId,
  ItemLocationModel? editLocation,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => EditItemLocationDialog(
      itemId: itemId,
      editLocation: editLocation,
    ),
  ).then((value) => value ?? false);
}

class EditItemLocationDialog extends ConsumerStatefulWidget {
  const EditItemLocationDialog({
    required this.itemId,
    this.editLocation,
    super.key,
  });

  final String itemId;
  final ItemLocationModel? editLocation;

  @override
  ConsumerState<EditItemLocationDialog> createState() =>
      _EditItemLocationDialogState();
}

class _EditItemLocationDialogState
    extends ConsumerState<EditItemLocationDialog> {
  final _rackController = TextEditingController();
  final _shelfController = TextEditingController();
  String? _godownId;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editLocation != null;

  @override
  void initState() {
    super.initState();
    if (widget.editLocation != null) {
      _godownId = widget.editLocation!.godownId;
      _rackController.text = widget.editLocation!.rack ?? '';
      _shelfController.text = widget.editLocation!.shelf ?? '';
    }
  }

  @override
  void dispose() {
    _rackController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isLoading) return;
    if (!_isEditing && _godownId == null) {
      setState(() => _errorMessage = 'Select a godown.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      if (_isEditing) {
        await service.updateItemLocation(
          widget.editLocation!.id,
          rack: _rackController.text.trim(),
          shelf: _shelfController.text.trim(),
        );
      } else {
        await service.createItemLocation(
          itemId: widget.itemId,
          godownId: _godownId!,
          rack: _rackController.text.trim(),
          shelf: _shelfController.text.trim(),
        );
      }

      ref.invalidate(itemLocationsProvider(widget.itemId));
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    final godowns = ref.watch(inventoryGodownsProvider).value ?? [];
    _godownId ??= godowns.isNotEmpty ? godowns.first.id : null;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Location' : 'Add Location'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isEditing) ...[
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
            ],
            const Text('Rack', style: saleFieldLabelStyle),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _rackController,
              decoration: buildSaleFieldDecoration(hint: 'Rack'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Shelf', style: saleFieldLabelStyle),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _shelfController,
              decoration: buildSaleFieldDecoration(hint: 'Shelf'),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
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
              : Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
