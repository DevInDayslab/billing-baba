import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:flutter/material.dart';

class DefaultUnitsSelection {
  const DefaultUnitsSelection({
    required this.baseUnitId,
    required this.secondaryUnitId,
  });

  final String? baseUnitId;
  final String? secondaryUnitId;
}

Future<DefaultUnitsSelection?> showSelectDefaultUnitsDialog({
  required BuildContext context,
  required List<InventoryUnit> units,
  required String? baseUnitId,
  required String? secondaryUnitId,
}) {
  return showDialog<DefaultUnitsSelection>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _SelectDefaultUnitsDialog(
      units: units,
      initialBaseId: baseUnitId,
      initialSecondaryId: secondaryUnitId,
    ),
  );
}

class _SelectDefaultUnitsDialog extends StatefulWidget {
  const _SelectDefaultUnitsDialog({
    required this.units,
    required this.initialBaseId,
    required this.initialSecondaryId,
  });

  final List<InventoryUnit> units;
  final String? initialBaseId;
  final String? initialSecondaryId;

  @override
  State<_SelectDefaultUnitsDialog> createState() =>
      _SelectDefaultUnitsDialogState();
}

class _SelectDefaultUnitsDialogState extends State<_SelectDefaultUnitsDialog> {
  late String? _baseId;
  late String? _secondaryId;

  @override
  void initState() {
    super.initState();
    _baseId = widget.initialBaseId;
    _secondaryId = widget.initialSecondaryId;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Select Default Unit',
                style: AppTypography.inter(
                  fontSize: AppTypography.titleMediumSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: listPanelCardBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stack = constraints.maxWidth < 480;
                  final base = _UnitDropdown(
                    label: 'DEFAULT BASE UNIT',
                    value: _baseId,
                    units: widget.units,
                    onChanged: (id) => setState(() => _baseId = id),
                  );
                  final secondary = _UnitDropdown(
                    label: 'DEFAULT SECONDARY UNIT',
                    value: _secondaryId,
                    units: widget.units,
                    onChanged: (id) => setState(() => _secondaryId = id),
                  );
                  if (stack) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        base,
                        const SizedBox(height: AppSpacing.md),
                        secondary,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: base),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: secondary),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1, color: listPanelCardBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    DefaultUnitsSelection(
                      baseUnitId: _baseId,
                      secondaryUnitId: _secondaryId,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('SAVE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.units,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<InventoryUnit> units;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String?>(
          isExpanded: true,
          value: value,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: AppRadius.smBorder),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('None', overflow: TextOverflow.ellipsis),
            ),
            for (final unit in units)
              DropdownMenuItem(
                value: unit.id,
                child: Text(unit.fullName, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

Future<String?> showEditItemFieldLabelDialog({
  required BuildContext context,
  required String title,
  required String initialValue,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _EditTextDialog(title: title, initial: initialValue),
  );
}

class _EditTextDialog extends StatefulWidget {
  const _EditTextDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: AppTypography.inter(
                  fontSize: AppTypography.titleMediumSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.smBorder,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, _controller.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
