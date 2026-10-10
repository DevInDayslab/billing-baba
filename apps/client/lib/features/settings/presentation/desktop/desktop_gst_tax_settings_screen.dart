import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/application/gst_tax_settings_provider.dart';
import 'package:billing_baba/features/settings/application/tax_rate_providers.dart';
import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/models/gst_tax_catalog.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings.dart';
import 'package:billing_baba/features/settings/models/gst_tax_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopGstTaxSettingsScreen extends ConsumerStatefulWidget {
  const DesktopGstTaxSettingsScreen({super.key});

  @override
  ConsumerState<DesktopGstTaxSettingsScreen> createState() =>
      _DesktopGstTaxSettingsScreenState();
}

class _DesktopGstTaxSettingsScreenState
    extends ConsumerState<DesktopGstTaxSettingsScreen> {
  var _taxListOpen = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(gstTaxSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load GST settings: $error',
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (settings) {
        Future<void> patch(GstTaxSettings Function(GstTaxSettings) update) {
          return ref.read(gstTaxSettingsProvider.notifier).patch(update);
        }

        final settingsColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                    Text(
                      'GST Settings',
                      style: AppTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: AppSpacing.lg),
                    _GstCheckbox(
                      label: 'Enable GST',
                      value: settings.enableGst,
                      infoKey: GstTaxSettingsInfoKey.enableGst,
                      onChanged: (v) =>
                          patch((s) => s.copyWith(enableGst: v ?? false)),
                    ),
                    _GstCheckbox(
                      label: 'Enable HSN/SAC Code',
                      value: settings.enableHsnSac,
                      infoKey: GstTaxSettingsInfoKey.hsnSac,
                      onChanged: settings.enableGst
                          ? (v) => patch(
                              (s) => s.copyWith(enableHsnSac: v ?? false),
                            )
                          : null,
                    ),
                    _GstCheckbox(
                      label: 'Additional Cess On Item',
                      value: settings.additionalCessOnItem,
                      infoKey: GstTaxSettingsInfoKey.additionalCess,
                      onChanged: settings.enableGst
                          ? (v) => patch(
                              (s) =>
                                  s.copyWith(additionalCessOnItem: v ?? false),
                            )
                          : null,
                    ),
                    _GstCheckbox(
                      label: 'Reverse Charge',
                      value: settings.reverseCharge,
                      infoKey: GstTaxSettingsInfoKey.reverseCharge,
                      onChanged: settings.enableGst && !settings.compositeScheme
                          ? (v) => patch(
                              (s) => s.copyWith(reverseCharge: v ?? false),
                            )
                          : null,
                    ),
                    _GstCheckbox(
                      label: 'Enable Place of Supply',
                      value: settings.enablePlaceOfSupply,
                      infoKey: GstTaxSettingsInfoKey.placeOfSupply,
                      onChanged: settings.enableGst
                          ? (v) => patch(
                              (s) =>
                                  s.copyWith(enablePlaceOfSupply: v ?? false),
                            )
                          : null,
                    ),
                    _GstCheckbox(
                      label: 'Composite Scheme',
                      value: settings.compositeScheme,
                      infoKey: GstTaxSettingsInfoKey.compositeScheme,
                      onChanged: settings.enableGst
                          ? (v) => patch((s) {
                              final enabled = v ?? false;
                              return s.copyWith(
                                compositeScheme: enabled,
                                reverseCharge: enabled
                                    ? false
                                    : s.reverseCharge,
                              );
                            })
                          : null,
                    ),
                    if (settings.enableGst && settings.compositeScheme)
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Column(
                          children: [
                            for (final category
                                in CompositeBusinessCategory.values)
                              RadioListTile<CompositeBusinessCategory>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(category.label),
                                value: category,
                                groupValue: settings.compositeCategory,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  if (value == null) return;
                                  patch(
                                    (s) => s.copyWith(compositeCategory: value),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    _GstCheckbox(
                      label: 'Enable TCS',
                      value: settings.enableTcs,
                      infoKey: GstTaxSettingsInfoKey.enableTcs,
                      onChanged: settings.enableGst && !settings.compositeScheme
                          ? (v) =>
                                patch((s) => s.copyWith(enableTcs: v ?? false))
                          : null,
                    ),
                    _GstCheckbox(
                      label: 'Enable TDS',
                      value: settings.enableTds,
                      infoKey: GstTaxSettingsInfoKey.enableTds,
                      onChanged: (v) =>
                          patch((s) => s.copyWith(enableTds: v ?? false)),
                    ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _taxListOpen = !_taxListOpen),
                child: const Text('Tax List >'),
              ),
            ),
          ],
        );

        final ratesColumn = const _TaxRatesColumn();
        final groupsColumn = const _TaxGroupsColumn();

        return ColoredBox(
          color: AppColors.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980 && _taxListOpen;
              final border = BorderSide(
                color: Theme.of(context).dividerColor,
              );
              final Widget body;
              if (!_taxListOpen) {
                body = settingsColumn;
              } else if (wide) {
                body = IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(right: border),
                          ),
                          child: settingsColumn,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(right: border),
                          ),
                          child: ratesColumn,
                        ),
                      ),
                      Expanded(flex: 5, child: groupsColumn),
                    ],
                  ),
                );
              } else {
                body = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    settingsColumn,
                    Divider(height: 1, color: border.color),
                    ratesColumn,
                    Divider(height: 1, color: border.color),
                    groupsColumn,
                  ],
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: body,
              );
            },
          ),
        );
      },
    );
  }
}

class _GstCheckbox extends StatelessWidget {
  const _GstCheckbox({
    required this.label,
    required this.value,
    required this.infoKey,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final GstTaxSettingsInfoKey infoKey;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            label,
            style: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          SettingsInfoHoverIcon(
            heading: label,
            sections: GstTaxSettingsInfoCatalog.sectionsFor(infoKey),
          ),
        ],
      ),
    );
  }
}

class _TaxRatesColumn extends ConsumerWidget {
  const _TaxRatesColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(taxRatesProvider);
    return ratesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text('Could not load tax rates: $error'),
      ),
      data: (rates) {
        final sorted = [...rates]..sort(compareTaxRatesForDisplay);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ColumnTitle(
              title: 'Tax Rates',
              info:
                  'Individual tax components such as IGST, SGST and CGST. A tax group is built from the SGST and CGST pair for the same slab.',
            ),
            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('No tax rates for this business.'),
              )
            else
              for (final rate in sorted)
                _RateRow(
                  name: rate.name,
                  trailing: formatTaxPercent(
                    double.tryParse(rate.rate) ?? 0,
                  ),
                  onEdit: () => showEditTaxRateDialog(context, ref, rate),
                  onDelete: () => ref
                      .read(taxRatesProvider.notifier)
                      .deleteRate(rate.id),
                ),
          ],
        );
      },
    );
  }
}

class _TaxGroupsColumn extends ConsumerWidget {
  const _TaxGroupsColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(taxRatesProvider);
    return ratesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rates) {
        final groups = deriveGstTaxGroups(rates);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ColumnTitle(
              title: 'Tax Group',
              info:
                  'A tax group combines SGST and CGST components into one GST rate used on invoices.',
            ),
            if (groups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('No tax groups yet. Add matching SGST and CGST rates.'),
              )
            else
              for (final group in groups)
                _RateRow(
                  name: group.name,
                  subtitle: group.members.map((m) => m.name).join('   '),
                  onEdit: () => showEditTaxGroupDialog(context, ref, group),
                  onDelete: () async {
                    final notifier = ref.read(taxRatesProvider.notifier);
                    for (final member in group.members) {
                      await notifier.deleteRate(member.id);
                    }
                  },
                ),
          ],
        );
      },
    );
  }
}

class _ColumnTitle extends StatelessWidget {
  const _ColumnTitle({required this.title, required this.info});

  final String title;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          SettingsInfoHoverIcon(
            heading: title,
            sections: [SettingsInfoSection(title: 'What is this?', body: info)],
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.name,
    required this.onEdit,
    required this.onDelete,
    this.trailing,
    this.subtitle,
  });

  final String name;
  final String? trailing;
  final String? subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodyMediumSize,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                SizedBox(
                  width: 56,
                  child: Text(
                    trailing!,
                    style: AppTypography.inter(
                      fontSize: AppTypography.bodySmallSize,
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              IconButton(
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

Future<void> showEditTaxRateDialog(
  BuildContext context,
  WidgetRef ref,
  TaxRateDto rate,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _EditTaxRateDialog(rate: rate),
  );
}

class _EditTaxRateDialog extends ConsumerStatefulWidget {
  const _EditTaxRateDialog({required this.rate});

  final TaxRateDto rate;

  @override
  ConsumerState<_EditTaxRateDialog> createState() => _EditTaxRateDialogState();
}

class _EditTaxRateDialogState extends ConsumerState<_EditTaxRateDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late String _kind;

  @override
  void initState() {
    super.initState();
    final parsed = parseGstTaxRate(widget.rate.name, widget.rate.rate);
    _kind = parsed.isExempt ? 'Exempt' : (parsed.kind ?? gstComponentKinds.first);
    _nameController = TextEditingController(text: widget.rate.name);
    _rateController = TextEditingController(
      text: formatTaxPercent(parsed.percent),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final percent = double.tryParse(_rateController.text.trim());
    if (percent == null) return;
    final name = _kind == 'Exempt'
        ? 'Exempt'
        : taxRateName(kind: _kind, percent: percent);
    _nameController.text = name;
    await ref.read(taxRatesProvider.notifier).updateRate(
      widget.rate.id,
      UpdateTaxRateRequest(name: name, rate: formatTaxPercent(percent)),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final kinds = <String>{
      ...gstComponentKinds,
      'Exempt',
      _kind,
    }.toList();
    return AlertDialog(
      title: const Text('Edit Tax Rate'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tax Name'),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(isDense: true),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Rate'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (value) {
                      final percent = double.tryParse(value);
                      if (percent == null || _kind == 'Exempt') return;
                      _nameController.text = taxRateName(
                        kind: _kind,
                        percent: percent,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _kind,
                    isExpanded: true,
                    decoration: const InputDecoration(isDense: true),
                    items: [
                      for (final kind in kinds)
                        DropdownMenuItem(value: kind, child: Text(kind)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _kind = value;
                        final percent = double.tryParse(_rateController.text);
                        if (value == 'Exempt') {
                          _nameController.text = 'Exempt';
                        } else if (percent != null) {
                          _nameController.text = taxRateName(
                            kind: value,
                            percent: percent,
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(onPressed: _save, child: const Text('SAVE')),
      ],
    );
  }
}

Future<void> showEditTaxGroupDialog(
  BuildContext context,
  WidgetRef ref,
  GstTaxGroup group,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _EditTaxGroupDialog(group: group),
  );
}

class _EditTaxGroupDialog extends ConsumerStatefulWidget {
  const _EditTaxGroupDialog({required this.group});

  final GstTaxGroup group;

  @override
  ConsumerState<_EditTaxGroupDialog> createState() =>
      _EditTaxGroupDialogState();
}

class _EditTaxGroupDialogState extends ConsumerState<_EditTaxGroupDialog> {
  late final TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: formatTaxPercent(widget.group.totalPercent),
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final total = double.tryParse(_rateController.text.trim());
    if (total == null) return;
    final half = total / 2;
    final notifier = ref.read(taxRatesProvider.notifier);
    for (final member in widget.group.members) {
      final parsed = parseGstTaxRate(member.name, member.rate);
      final kind = parsed.kind;
      if (kind == null) continue;
      await notifier.updateRate(
        member.id,
        UpdateTaxRateRequest(
          name: taxRateName(kind: kind, percent: half),
          rate: formatTaxPercent(half),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final total = double.tryParse(_rateController.text.trim());
    final preview = total == null
        ? widget.group.name
        : 'GST@${formatTaxPercent(total)}%';
    return AlertDialog(
      title: const Text('Edit Tax Group'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(preview),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.group.members.map((m) => m.name).join('   '),
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Group rate'),
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(isDense: true),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(onPressed: _save, child: const Text('SAVE')),
      ],
    );
  }
}
