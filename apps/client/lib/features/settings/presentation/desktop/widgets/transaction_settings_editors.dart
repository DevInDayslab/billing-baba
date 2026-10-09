import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';
import 'package:billing_baba/features/settings/application/tax_rate_providers.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionPrefixChoice {
  const TransactionPrefixChoice({
    required this.value,
    required this.label,
    this.badge,
    this.badgeIsPrimary = false,
  });

  final String value;
  final String label;
  final String? badge;
  final bool badgeIsPrimary;
}

List<TransactionPrefixChoice> transactionPrefixChoices({
  required SaleTransactionPrefixType type,
  required String firmName,
  required DateTime now,
  required List<String> customPrefixes,
}) {
  final startYear = now.month >= 4 ? now.year : now.year - 1;
  final endShort = ((startYear + 1) % 100).toString().padLeft(2, '0');
  final startShort = (startYear % 100).toString().padLeft(2, '0');
  final fullYear = '$startYear-$endShort';
  final shortYear = 'FY$startShort-$endShort';
  final initials = _firmInitials(firmName);

  final choices = <TransactionPrefixChoice>[
    const TransactionPrefixChoice(value: '', label: 'None'),
    TransactionPrefixChoice(
      value: fullYear,
      label: fullYear,
      badge: 'MOST USED',
      badgeIsPrimary: true,
    ),
    TransactionPrefixChoice(
      value: shortYear,
      label: shortYear,
      badge: 'Financial Year',
    ),
    TransactionPrefixChoice(
      value: type.defaultPrefix,
      label:
          '${type.defaultPrefix} (${type.defaultPrefix}- for ${type.label} etc.)',
    ),
  ];
  if (initials.isNotEmpty) {
    choices.add(
      TransactionPrefixChoice(
        value: initials,
        label: '$initials (Firm name initials)',
      ),
    );
  }
  for (final custom in customPrefixes) {
    if (choices.any((c) => c.value == custom)) continue;
    choices.add(TransactionPrefixChoice(value: custom, label: custom));
  }
  return choices;
}

String _firmInitials(String firmName) {
  final words = firmName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  if (words.length == 1) {
    final word = words.first.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (word.isEmpty) return '';
    final length = word.length >= 2 ? 2 : 1;
    return word.substring(0, length).toUpperCase();
  }
  return words.take(3).map((word) => word[0].toUpperCase()).join();
}

class TransactionPrefixField extends ConsumerStatefulWidget {
  const TransactionPrefixField({
    required this.type,
    required this.selected,
    required this.firmName,
    required this.customPrefixes,
    required this.onSelected,
    required this.onAddCustom,
    super.key,
  });

  final SaleTransactionPrefixType type;
  final String selected;
  final String firmName;
  final List<String> customPrefixes;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onAddCustom;

  @override
  ConsumerState<TransactionPrefixField> createState() =>
      _TransactionPrefixFieldState();
}

class _TransactionPrefixFieldState extends ConsumerState<TransactionPrefixField> {
  final _menuController = MenuController();
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choices = transactionPrefixChoices(
      type: widget.type,
      firmName: widget.firmName,
      now: DateTime.now(),
      customPrefixes: widget.customPrefixes,
    );
    final matches = choices.where((c) => c.value == widget.selected);
    final current = matches.isNotEmpty
        ? matches.first
        : (widget.selected.isEmpty
              ? choices.first
              : TransactionPrefixChoice(
                  value: widget.selected,
                  label: widget.selected,
                ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.type.label,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        MenuAnchor(
          controller: _menuController,
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.surface),
            elevation: WidgetStateProperty.all(8),
          ),
          menuChildren: [
            for (final choice in choices)
              MenuItemButton(
                onPressed: () => widget.onSelected(choice.value),
                child: _PrefixChoiceLabel(choice: choice),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addController,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Custom prefix',
                      ),
                      onSubmitted: _add,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _add(_addController.text),
                    child: const Text('ADD'),
                  ),
                ],
              ),
            ),
          ],
          builder: (context, controller, child) {
            return InkWell(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: listPanelCardBorder),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        current.value.isEmpty ? 'None' : current.value,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _add(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    widget.onAddCustom(value);
    widget.onSelected(value);
    _addController.clear();
    if (_menuController.isOpen) _menuController.close();
  }
}

class _PrefixChoiceLabel extends StatelessWidget {
  const _PrefixChoiceLabel({required this.choice});

  final TransactionPrefixChoice choice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            choice.label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.inter(fontSize: AppTypography.bodySmallSize),
          ),
        ),
        if (choice.badge != null) ...[
          const SizedBox(width: 8),
          Text(
            choice.badge!,
            style: AppTypography.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: choice.badgeIsPrimary
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> showPaymentTermsEditor({
  required BuildContext context,
  required List<PaymentTermSetting> initial,
  required Future<void> Function(List<PaymentTermSetting>) onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PaymentTermsDialog(initial: initial, onSave: onSave),
  );
}

class _PaymentTermsDialog extends StatefulWidget {
  const _PaymentTermsDialog({required this.initial, required this.onSave});

  final List<PaymentTermSetting> initial;
  final Future<void> Function(List<PaymentTermSetting>) onSave;

  @override
  State<_PaymentTermsDialog> createState() => _PaymentTermsDialogState();
}

class _PaymentTermsDialogState extends State<_PaymentTermsDialog> {
  late List<PaymentTermSetting> _terms;

  @override
  void initState() {
    super.initState();
    _terms = [...widget.initial];
  }

  void _setDefault(int index, bool value) {
    setState(() {
      _terms = [
        for (var i = 0; i < _terms.length; i++)
          _terms[i].copyWith(isDefault: value && i == index),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Payment Terms'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _terms = [
                        ..._terms,
                        PaymentTermSetting(
                          id: 'term_${DateTime.now().microsecondsSinceEpoch}',
                          name: '',
                          days: 0,
                          isDefault: false,
                        ),
                      ];
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: const [
                  Expanded(flex: 3, child: Text('Term')),
                  Expanded(child: Text('Days')),
                  SizedBox(width: 72, child: Text('Default')),
                ],
              ),
              for (var i = 0; i < _terms.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: _terms[i].name,
                          decoration: const InputDecoration(isDense: true),
                          onChanged: (v) => _terms[i] = _terms[i].copyWith(
                            name: v,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: '${_terms[i].days}',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(isDense: true),
                          onChanged: (v) => _terms[i] = _terms[i].copyWith(
                            days: int.tryParse(v) ?? 0,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: _terms[i].isDefault,
                        onChanged: (v) => _setDefault(i, v ?? false),
                      ),
                      if (!_terms[i].locked)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _terms.removeAt(i)),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            await widget.onSave(
              _terms.where((t) => t.name.trim().isNotEmpty).toList(),
            );
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('DONE'),
        ),
      ],
    );
  }
}

Future<void> showTransportationEditor({
  required BuildContext context,
  required List<TransportFieldSetting> initial,
  required Future<void> Function(List<TransportFieldSetting>) onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _TransportDialog(initial: initial, onSave: onSave),
  );
}

class _TransportDialog extends StatefulWidget {
  const _TransportDialog({required this.initial, required this.onSave});

  final List<TransportFieldSetting> initial;
  final Future<void> Function(List<TransportFieldSetting>) onSave;

  @override
  State<_TransportDialog> createState() => _TransportDialogState();
}

class _TransportDialogState extends State<_TransportDialog> {
  late List<TransportFieldSetting> _fields;

  @override
  void initState() {
    super.initState();
    _fields = [...widget.initial];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transportation Details'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (var i = 0; i < _fields.length; i++) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Field ${i + 1} *',
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _fields[i].enabled,
                      onChanged: (v) => setState(() {
                        _fields[i] = _fields[i].copyWith(enabled: v ?? false);
                      }),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: _fields[i].label,
                  decoration: const InputDecoration(isDense: true),
                  onChanged: (v) => _fields[i] = _fields[i].copyWith(label: v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show in print'),
                  value: _fields[i].showInPrint,
                  onChanged: (v) => setState(() {
                    _fields[i] = _fields[i].copyWith(showInPrint: v);
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            await widget.onSave(_fields);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('DONE'),
        ),
      ],
    );
  }
}

Future<void> showAdditionalChargesEditor({
  required BuildContext context,
  required WidgetRef ref,
  required bool enabled,
  required List<AdditionalChargeSetting> charges,
  required Future<void> Function(
    bool enabled,
    List<AdditionalChargeSetting> charges,
  )
  onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AdditionalChargesDialog(
      enabled: enabled,
      charges: charges,
      onSave: onSave,
    ),
  );
}

class _AdditionalChargesDialog extends ConsumerStatefulWidget {
  const _AdditionalChargesDialog({
    required this.enabled,
    required this.charges,
    required this.onSave,
  });

  final bool enabled;
  final List<AdditionalChargeSetting> charges;
  final Future<void> Function(
    bool enabled,
    List<AdditionalChargeSetting> charges,
  )
  onSave;

  @override
  ConsumerState<_AdditionalChargesDialog> createState() =>
      _AdditionalChargesDialogState();
}

class _AdditionalChargesDialogState
    extends ConsumerState<_AdditionalChargesDialog> {
  late bool _enabled;
  late List<AdditionalChargeSetting> _charges;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
    _charges = [...widget.charges];
  }

  @override
  Widget build(BuildContext context) {
    final rates = ref.watch(taxRatesProvider).asData?.value ?? const <TaxRateDto>[];
    return AlertDialog(
      title: const Text('Additional Charges'),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Additional Charges'),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              const Divider(),
              for (var i = 0; i < _charges.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _charges[i].selected,
                        onChanged: (v) => setState(() {
                          _charges[i] = _charges[i].copyWith(
                            selected: v ?? false,
                          );
                        }),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Additional Charge ${i + 1} *'),
                            TextFormField(
                              initialValue: _charges[i].name,
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (v) =>
                                  _charges[i] = _charges[i].copyWith(name: v),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Enable tax for ${_charges[i].name}',
                              ),
                              value: _charges[i].taxEnabled,
                              onChanged: (v) => setState(() {
                                _charges[i] = _charges[i].copyWith(
                                  taxEnabled: v,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Default SAC'),
                            TextFormField(
                              initialValue: _charges[i].defaultSac,
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Enter SAC',
                              ),
                              onChanged: (v) => _charges[i] = _charges[i]
                                  .copyWith(defaultSac: v),
                            ),
                            Text(
                              'Can be changed during transaction',
                              style: AppTypography.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Tax Rate'),
                            DropdownButtonFormField<String>(
                              value: _charges[i].taxRateId,
                              isExpanded: true,
                              decoration: const InputDecoration(isDense: true),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('NONE'),
                                ),
                                for (final rate in rates)
                                  DropdownMenuItem(
                                    value: rate.id,
                                    child: Text('${rate.name} (${rate.rate}%)'),
                                  ),
                              ],
                              onChanged: (v) => setState(() {
                                _charges[i] = _charges[i].copyWith(
                                  taxRateId: v ?? '',
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
            await widget.onSave(_enabled, _charges);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Save Details'),
        ),
      ],
    );
  }
}
