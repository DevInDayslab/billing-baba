import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mobile bottom sheet for creating or editing a unit (Vyapar-style).
Future<InventoryUnit?> showMobileAddUnitSheet(
  BuildContext context, {
  InventoryUnit? editUnit,
}) {
  return showModalBottomSheet<InventoryUnit>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: AppColors.surface,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: _AddUnitSheetBody(
                sheetContext: sheetContext,
                editUnit: editUnit,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AddUnitSheetBody extends ConsumerStatefulWidget {
  const _AddUnitSheetBody({
    required this.sheetContext,
    this.editUnit,
  });

  final BuildContext sheetContext;
  final InventoryUnit? editUnit;

  @override
  ConsumerState<_AddUnitSheetBody> createState() => _AddUnitSheetBodyState();
}

class _AddUnitSheetBodyState extends ConsumerState<_AddUnitSheetBody> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _shortNameController;
  late final FocusNode _fullNameFocusNode;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editUnit != null;

  static const _fieldBorderColor = Color(0xFFE0E0E0);
  static const _cancelBg = Color(0xFFF0F2F5);

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.editUnit?.fullName ?? '',
    );
    _shortNameController = TextEditingController(
      text: widget.editUnit?.shortName ?? '',
    );
    _fullNameFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fullNameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _shortNameController.dispose();
    _fullNameFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.75),
        fontSize: 14,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(_fieldBorderColor),
      enabledBorder: border(_fieldBorderColor),
      focusedBorder: border(AppColors.primary, width: 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 1.5),
    );
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

    Navigator.of(widget.sheetContext).pop(result.unit);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Unit' : 'Add Unit';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(widget.sheetContext).pop(),
                icon: const Icon(LucideIcons.x),
                color: AppColors.textSecondary,
                iconSize: 22,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _fullNameController,
            focusNode: _fullNameFocusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _fieldDecoration('Enter Full Unit Name'),
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _shortNameController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _fieldDecoration('Short Name'),
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
                child: Material(
                  color: _cancelBg,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: _isLoading
                        ? null
                        : () => Navigator.of(widget.sheetContext).pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Material(
                  color: MobileHomeAddSaleFab.accentRed,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: _isLoading ? null : _save,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
