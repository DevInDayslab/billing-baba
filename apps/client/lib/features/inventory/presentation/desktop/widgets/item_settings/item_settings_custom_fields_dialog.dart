import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/models/item_vyapar_settings.dart';
import 'package:flutter/material.dart';

Future<List<ItemCustomFieldSetting>?> showItemCustomFieldsDialog({
  required BuildContext context,
  required List<ItemCustomFieldSetting> initial,
}) {
  return showDialog<List<ItemCustomFieldSetting>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ItemCustomFieldsDialog(initial: initial),
  );
}

class _ItemCustomFieldsDialog extends StatefulWidget {
  const _ItemCustomFieldsDialog({required this.initial});

  final List<ItemCustomFieldSetting> initial;

  @override
  State<_ItemCustomFieldsDialog> createState() => _ItemCustomFieldsDialogState();
}

class _ItemCustomFieldsDialogState extends State<_ItemCustomFieldsDialog> {
  late List<ItemCustomFieldSetting> _fields;

  @override
  void initState() {
    super.initState();
    _fields = List<ItemCustomFieldSetting>.from(widget.initial);
    while (_fields.length < ItemFieldCatalog.customFieldCount) {
      _fields.add(ItemFieldCatalog.defaultCustomField(_fields.length));
    }
  }

  void _update(int index, ItemCustomFieldSetting field) {
    setState(() => _fields[index] = field);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
        child: Column(
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
                'Add Custom Fields',
                style: AppTypography.inter(
                  fontSize: AppTypography.titleMediumSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1, color: listPanelCardBorder),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final twoCol = constraints.maxWidth >= 520;
                    final children = <Widget>[];
                    for (var i = 0; i < ItemFieldCatalog.customFieldCount; i++) {
                      children.add(
                        _CustomFieldEditor(
                          index: i,
                          config: _fields[i],
                          onChanged: (f) => _update(i, f),
                        ),
                      );
                    }
                    if (!twoCol) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < children.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.md),
                            children[i],
                          ],
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (var row = 0; row < 3; row++) ...[
                          if (row > 0) const SizedBox(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: children[row * 2]),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(child: children[row * 2 + 1]),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1, color: listPanelCardBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _fields),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomFieldEditor extends StatelessWidget {
  const _CustomFieldEditor({
    required this.index,
    required this.config,
    required this.onChanged,
  });

  final int index;
  final ItemCustomFieldSetting config;
  final ValueChanged<ItemCustomFieldSetting> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = ItemFieldCatalog.defaultCustomFieldLabel(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: config.enabled,
              onChanged: (v) =>
                  onChanged(config.copyWith(enabled: v ?? false)),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              '$label*',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextFormField(
          initialValue: config.placeholder,
          enabled: config.enabled,
          decoration: InputDecoration(
            hintText: 'E.g: ${ItemFieldCatalog.defaultCustomFieldPlaceholder(index)}',
            isDense: true,
            border: OutlineInputBorder(borderRadius: AppRadius.smBorder),
          ),
          onChanged: (v) => onChanged(config.copyWith(placeholder: v)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Show in print',
              style: AppTypography.inter(
                fontSize: AppTypography.captionSize,
                color: AppColors.textSecondary,
              ),
            ),
            Switch(
              value: config.showInPrint,
              onChanged: config.enabled
                  ? (v) => onChanged(config.copyWith(showInPrint: v))
                  : null,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
