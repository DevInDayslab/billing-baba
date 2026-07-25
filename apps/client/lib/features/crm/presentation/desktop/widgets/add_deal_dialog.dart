import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _dialogMaxWidth = 960.0;
const _cardBorder = Color(0xFFE0E0E0);
const _saveRed = Color(0xFFE53935);
const _requiredAccent = Color(0xFFD32F2F);

const _ownerOptions = [
  '-None-',
  'Saksham Kochhar',
  'Priya Mehta',
  'Amit Verma',
];

const _typeOptions = [
  '-None-',
  'New Business',
  'Existing Business',
];

class AddDealInput {
  const AddDealInput({
    required this.name,
    this.stage = DealStage.qualification,
    this.accountName,
    this.owner,
    this.amount = 0,
    this.expectedCloseDate,
    this.description,
  });

  final String name;
  final DealStage stage;
  final String? accountName;
  final String? owner;
  final double amount;
  final DateTime? expectedCloseDate;
  final String? description;
}

Future<AddDealInput?> showAddDealDialog(
  BuildContext context, {
  ValueChanged<AddDealInput>? onSaveAndNew,
}) {
  return showDialog<AddDealInput>(
    context: context,
    builder: (context) => AddDealDialog(onSaveAndNew: onSaveAndNew),
  );
}

class AddDealDialog extends StatefulWidget {
  const AddDealDialog({this.onSaveAndNew, super.key});

  final ValueChanged<AddDealInput>? onSaveAndNew;

  @override
  State<AddDealDialog> createState() => _AddDealDialogState();
}

class _AddDealDialogState extends State<AddDealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _closeDateController = TextEditingController();
  final _nextStepController = TextEditingController();
  final _probabilityController = TextEditingController(text: '10');
  final _contactController = TextEditingController();
  final _campaignController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _owner = 'Saksham Kochhar';
  String _stageLabel = DealStage.qualification.label;
  String _type = '-None-';
  String _leadSource = '-None-';

  bool _nameError = false;
  bool _accountError = false;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 2,
  );

  List<String> get _stageOptions =>
      DealStageX.pipelineStages.map((stage) => stage.label).toList();

  List<String> get _leadSourceOptions => [
    '-None-',
    ...LeadSource.values.map((source) => source.label),
  ];

  DealStage get _selectedStage => DealStageX.pipelineStages.firstWhere(
    (stage) => stage.label == _stageLabel,
    orElse: () => DealStage.qualification,
  );

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  int get _probability =>
      int.tryParse(_probabilityController.text.trim()) ??
      _selectedStage.probability;

  String get _expectedRevenueDisplay {
    final revenue = _amount * _probability / 100;
    return _currencyFormat.format(revenue);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _closeDateController.dispose();
    _nextStepController.dispose();
    _probabilityController.dispose();
    _contactController.dispose();
    _campaignController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncProbabilityFromStage() {
    _probabilityController.text = '${_selectedStage.probability}';
  }

  String? _nullableValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '-None-') return null;
    return trimmed;
  }

  DateTime? _parseCloseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  Future<void> _pickCloseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _closeDateController.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    });
  }

  bool _validate() {
    final nameEmpty = _nameController.text.trim().isEmpty;
    final accountEmpty = _accountController.text.trim().isEmpty;
    setState(() {
      _nameError = nameEmpty;
      _accountError = accountEmpty;
    });
    return !nameEmpty && !accountEmpty;
  }

  AddDealInput? _buildInput() {
    if (!_validate()) return null;
    return AddDealInput(
      name: _nameController.text.trim(),
      stage: _selectedStage,
      accountName: _nullableValue(_accountController.text),
      owner: _owner == '-None-' ? null : _owner,
      amount: _amount,
      expectedCloseDate: _parseCloseDate(_closeDateController.text),
      description: _nullableValue(_descriptionController.text),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _accountController.clear();
    _amountController.clear();
    _closeDateController.clear();
    _nextStepController.clear();
    _contactController.clear();
    _campaignController.clear();
    _descriptionController.clear();
    setState(() {
      _owner = 'Saksham Kochhar';
      _stageLabel = DealStage.qualification.label;
      _type = '-None-';
      _leadSource = '-None-';
      _nameError = false;
      _accountError = false;
      _syncProbabilityFromStage();
    });
  }

  void _save({required bool closeOnSave}) {
    final input = _buildInput();
    if (input == null) return;
    if (closeOnSave) {
      Navigator.of(context).pop(input);
      return;
    }
    widget.onSaveAndNew?.call(input);
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(
      size.width - (size.width < 640 ? AppSpacing.sm * 2 : AppSpacing.lg * 2),
      _dialogMaxWidth,
    );
    final maxDialogHeight = size.height * FormSpacing.dialogMaxHeightFactor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width < 640 ? AppSpacing.sm : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AddDealDialogHeader(
                onCancel: () => Navigator.of(context).pop(),
                onSaveAndNew: () => _save(closeOnSave: false),
                onSave: () => _save(closeOnSave: true),
              ),
              const Divider(height: 1, color: _cardBorder),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    FormSpacing.page,
                    FormSpacing.page,
                    FormSpacing.page,
                    FormSpacing.section,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormSection(
                          title: 'Deal Information',
                          child: FormGrid(
                            cells: [
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Deal Owner',
                                  child: SaleGenericSelectDropdown(
                                    value: _owner,
                                    hintText: '-None-',
                                    options: _ownerOptions,
                                    onSelected: (value) =>
                                        setState(() => _owner = value),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Amount',
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                    ],
                                    decoration:
                                        buildSaleFieldDecoration(
                                          hint: 'Amount',
                                          suffixIcon: const Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                        ).copyWith(
                                          prefixText: 'Rs. ',
                                          prefixStyle: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: _RequiredFormField(
                                  label: 'Deal Name',
                                  hasError: _nameError,
                                  errorText: _nameError
                                      ? 'Deal name is required'
                                      : null,
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Deal name',
                                      hasError: _nameError,
                                      borderless: true,
                                    ),
                                    onChanged: (_) {
                                      if (_nameError) {
                                        setState(() => _nameError = false);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Closing Date',
                                  child: TextFormField(
                                    controller: _closeDateController,
                                    readOnly: true,
                                    onTap: _pickCloseDate,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'DD/MM/YYYY',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: _RequiredFormField(
                                  label: 'Account Name',
                                  hasError: _accountError,
                                  errorText: _accountError
                                      ? 'Account name is required'
                                      : null,
                                  child: TextFormField(
                                    controller: _accountController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Account name',
                                      hasError: _accountError,
                                      borderless: true,
                                      suffixIcon: const Icon(
                                        Icons.apartment_outlined,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    onChanged: (_) {
                                      if (_accountError) {
                                        setState(() => _accountError = false);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: _RequiredFormField(
                                  label: 'Stage',
                                  child: SaleGenericSelectDropdown(
                                    value: _stageLabel,
                                    hintText: 'Stage',
                                    options: _stageOptions,
                                    borderless: true,
                                    onSelected: (value) => setState(() {
                                      _stageLabel = value;
                                      _syncProbabilityFromStage();
                                    }),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Type',
                                  child: SaleGenericSelectDropdown(
                                    value: _type,
                                    hintText: '-None-',
                                    options: _typeOptions,
                                    onSelected: (value) =>
                                        setState(() => _type = value),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Probability (%)',
                                  child: TextFormField(
                                    controller: _probabilityController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Probability',
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Next Step',
                                  child: TextFormField(
                                    controller: _nextStepController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Next step',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Expected Revenue',
                                  child: _ReadOnlyField(
                                    value: _amount > 0
                                        ? _expectedRevenueDisplay
                                        : '',
                                    hint: 'Rs.',
                                    suffixIcon: const Icon(
                                      Icons.lock_outline,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Lead Source',
                                  child: SaleGenericSelectDropdown(
                                    value: _leadSource,
                                    hintText: '-None-',
                                    options: _leadSourceOptions,
                                    onSelected: (value) =>
                                        setState(() => _leadSource = value),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Campaign Source',
                                  child: TextFormField(
                                    controller: _campaignController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Campaign source',
                                      suffixIcon: const Icon(
                                        Icons.campaign_outlined,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Contact Name',
                                  child: TextFormField(
                                    controller: _contactController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Contact name',
                                      suffixIcon: const Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FormSpacing.section),
                        FormSection(
                          title: 'Description Information',
                          child: AppFormField(
                            label: 'Description',
                            fixedHeight: false,
                            child: TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: buildSaleFieldDecoration(
                                hint: 'Add a description for this deal',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDealDialogHeader extends StatelessWidget {
  const _AddDealDialogHeader({
    required this.onCancel,
    required this.onSaveAndNew,
    required this.onSave,
  });

  final VoidCallback onCancel;
  final VoidCallback onSaveAndNew;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        if (isCompact) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FormSpacing.page,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Deal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _headerActions(
                    onCancel: onCancel,
                    onSaveAndNew: onSaveAndNew,
                    onSave: onSave,
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: FormSpacing.headerHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
            child: Row(
              children: [
                const Text(
                  'Create Deal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ..._headerActions(
                  onCancel: onCancel,
                  onSaveAndNew: onSaveAndNew,
                  onSave: onSave,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _headerActions({
    required VoidCallback onCancel,
    required VoidCallback onSaveAndNew,
    required VoidCallback onSave,
  }) {
    return [
      TextButton(onPressed: onCancel, child: const Text('Cancel')),
      const SizedBox(width: AppSpacing.sm),
      OutlinedButton(
        onPressed: onSaveAndNew,
        child: const Text('Save and New'),
      ),
      const SizedBox(width: AppSpacing.sm),
      FilledButton(
        onPressed: onSave,
        style: FilledButton.styleFrom(
          backgroundColor: _saveRed,
          foregroundColor: Colors.white,
        ),
        child: const Text('Save'),
      ),
    ];
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.value,
    required this.hint,
    this.suffixIcon,
  });

  final String value;
  final String hint;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: FormSpacing.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: saleFieldBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty
                    ? Colors.grey.shade400
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
        ],
      ),
    );
  }
}

class _RequiredFormField extends StatelessWidget {
  const _RequiredFormField({
    required this.label,
    required this.child,
    this.hasError = false,
    this.errorText,
  });

  final String label;
  final Widget child;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: label,
      hasError: hasError,
      errorText: errorText,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? _requiredAccent : saleFieldBorderColor,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: FormSpacing.inputHeight,
                color: _requiredAccent,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
