import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile bottom sheet for creating or editing a unit.
Future<InventoryUnit?> showMobileAddUnitSheet(
  BuildContext context, {
  InventoryUnit? editUnit,
}) {
  return showMobileBottomSheet<InventoryUnit>(
    context: context,
    useRootNavigator: true,
    title: editUnit == null ? 'Add Unit' : 'Edit Unit',
    maxHeightFraction: 0.55,
    builder: (_) => _AddUnitSheetBody(editUnit: editUnit),
  );
}

class _AddUnitSheetBody extends ConsumerStatefulWidget {
  const _AddUnitSheetBody({this.editUnit});

  final InventoryUnit? editUnit;

  @override
  ConsumerState<_AddUnitSheetBody> createState() => _AddUnitSheetBodyState();
}

class _AddUnitSheetBodyState extends ConsumerState<_AddUnitSheetBody> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _shortNameController;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editUnit != null;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.editUnit?.fullName ?? '',
    );
    _shortNameController = TextEditingController(
      text: widget.editUnit?.shortName ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(inventoryUnitsProvider.notifier);
    final result = _isEditing
        ? await notifier.updateUnit(
            id: widget.editUnit!.id,
            fullName: _fullNameController.text,
            shortName: _shortNameController.text,
          )
        : await notifier.addUnit(
            fullName: _fullNameController.text,
            shortName: _shortNameController.text,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    if (!_isEditing) {
      ref.read(selectedUnitIdProvider.notifier).selected = result.unit!.id;
    }

    Navigator.of(context).pop(result.unit);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _fullNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter Full Unit Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _shortNameController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Short Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
          onSubmitted: (_) => _save(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorMessage!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: MobileHomeAddSaleFab.accentRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
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
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
