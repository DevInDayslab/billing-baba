import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _dialogMaxWidth = 960.0;
const _cardBorder = Color(0xFFE0E0E0);
const _saveRed = Color(0xFFE53935);
const _requiredAccent = Color(0xFFD32F2F);

const _salutationOptions = ['-None-', 'Mr.', 'Mrs.', 'Ms.', 'Dr.'];
const _industryOptions = [
  '-None-',
  'Technology',
  'Retail',
  'Manufacturing',
  'Healthcare',
  'Finance',
  'Education',
  'Other',
];
const _ratingOptions = [
  'None',
  'Acquired',
  'Active',
  'Market Failed',
  'Project Cancelled',
  'Shut Down',
];

Future<AddLeadInput?> showAddLeadDialog(
  BuildContext context, {
  ValueChanged<AddLeadInput>? onSaveAndNew,
}) {
  return showDialog<AddLeadInput>(
    context: context,
    builder: (context) => AddLeadDialog(onSaveAndNew: onSaveAndNew),
  );
}

class AddLeadDialog extends StatefulWidget {
  const AddLeadDialog({this.onSaveAndNew, super.key});

  final ValueChanged<AddLeadInput>? onSaveAndNew;

  @override
  State<AddLeadDialog> createState() => _AddLeadDialogState();
}

class _AddLeadDialogState extends State<AddLeadDialog> {
  final _formKey = GlobalKey<FormState>();

  final _leadOwnerController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _companyController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _faxController = TextEditingController();
  final _websiteController = TextEditingController();
  final _employeesController = TextEditingController();
  final _annualRevenueController = TextEditingController();
  final _secondaryEmailController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _salutation = '-None-';
  String _industry = '-None-';
  String _rating = 'None';
  String? _leadSourceLabel;
  LeadStatus _status = LeadStatus.newLead;
  bool _emailOptOut = false;

  bool _companyError = false;
  bool _lastNameError = false;
  bool _phoneError = false;

  @override
  void dispose() {
    _leadOwnerController.dispose();
    _firstNameController.dispose();
    _titleController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _companyController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _faxController.dispose();
    _websiteController.dispose();
    _employeesController.dispose();
    _annualRevenueController.dispose();
    _secondaryEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  LeadSource? get _leadSource {
    final label = _leadSourceLabel;
    if (label == null || label == '-None-') return null;
    for (final source in LeadSource.values) {
      if (source.label == label) return source;
    }
    return null;
  }

  String _buildLeadName() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  AddLeadInput _buildInput() {
    final description = _descriptionController.text.trim();
    return AddLeadInput(
      name: _buildLeadName(),
      phone: _phoneController.text.trim(),
      email: _nullable(_emailController.text),
      company: _nullable(_companyController.text),
      leadSource: _leadSource,
      status: _status,
      assignedTo: _nullable(_leadOwnerController.text),
      notes: description.isEmpty ? null : description,
      salutation: _salutation == '-None-' ? null : _salutation,
      firstName: _nullable(_firstNameController.text),
      lastName: _nullable(_lastNameController.text),
      title: _nullable(_titleController.text),
      mobile: _nullable(_mobileController.text),
      fax: _nullable(_faxController.text),
      website: _nullable(_websiteController.text),
      industry: _industry == '-None-' ? null : _industry,
      annualRevenue: _nullable(_annualRevenueController.text),
      emailOptOut: _emailOptOut,
      noOfEmployees: _nullable(_employeesController.text),
      rating: _rating == 'None' ? null : _rating,
      secondaryEmail: _nullable(_secondaryEmailController.text),
      description: description.isEmpty ? null : description,
    );
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _validate() {
    final companyEmpty = _companyController.text.trim().isEmpty;
    final lastNameEmpty = _lastNameController.text.trim().isEmpty;
    final phoneEmpty = _phoneController.text.trim().isEmpty;

    setState(() {
      _companyError = companyEmpty;
      _lastNameError = lastNameEmpty;
      _phoneError = phoneEmpty;
    });

    return !companyEmpty && !lastNameEmpty && !phoneEmpty;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _leadOwnerController.clear();
    _firstNameController.clear();
    _titleController.clear();
    _phoneController.clear();
    _mobileController.clear();
    _companyController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _faxController.clear();
    _websiteController.clear();
    _employeesController.clear();
    _annualRevenueController.clear();
    _secondaryEmailController.clear();
    _descriptionController.clear();
    setState(() {
      _salutation = '-None-';
      _industry = '-None-';
      _rating = 'None';
      _leadSourceLabel = null;
      _status = LeadStatus.newLead;
      _emailOptOut = false;
      _companyError = false;
      _lastNameError = false;
      _phoneError = false;
    });
  }

  void _save({required bool saveAndNew}) {
    if (!_validate()) return;
    final input = _buildInput();
    if (saveAndNew) {
      widget.onSaveAndNew?.call(input);
      _resetForm();
      return;
    }
    Navigator.of(context).pop(input);
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
              _AddLeadDialogHeader(
                onCancel: () => Navigator.of(context).pop(),
                onSaveAndNew: () => _save(saveAndNew: true),
                onSave: () => _save(saveAndNew: false),
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
                    child: FormSection(
                      title: 'Lead Information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormGrid(
                            cells: [
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Lead Owner',
                                  child: TextFormField(
                                    controller: _leadOwnerController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Lead owner',
                                      suffixIcon: const Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: _RequiredFormField(
                                  label: 'Company',
                                  hasError: _companyError,
                                  errorText: _companyError
                                      ? 'Company is required'
                                      : null,
                                  child: TextFormField(
                                    controller: _companyController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Company',
                                      hasError: _companyError,
                                      borderless: true,
                                    ),
                                    onChanged: (_) {
                                      if (_companyError) {
                                        setState(() => _companyError = false);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'First Name',
                                  fixedHeight: false,
                                  child: SizedBox(
                                    height: FormSpacing.inputHeight,
                                    child: FormRow(
                                      alwaysHorizontal: true,
                                      flexes: const [2, 5],
                                      children: [
                                        SaleGenericSelectDropdown(
                                          value: _salutation,
                                          hintText: '-None-',
                                          options: _salutationOptions,
                                          compact: true,
                                          onSelected: (value) => setState(
                                            () => _salutation = value,
                                          ),
                                        ),
                                        TextFormField(
                                          controller: _firstNameController,
                                          decoration: buildSaleFieldDecoration(
                                            hint: 'First name',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: _RequiredFormField(
                                  label: 'Last Name',
                                  hasError: _lastNameError,
                                  errorText: _lastNameError
                                      ? 'Last name is required'
                                      : null,
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Last name',
                                      hasError: _lastNameError,
                                      borderless: true,
                                    ),
                                    onChanged: (_) {
                                      if (_lastNameError) {
                                        setState(() => _lastNameError = false);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Title',
                                  child: TextFormField(
                                    controller: _titleController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Title',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Email',
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Email',
                                    ),
                                    validator: (value) {
                                      final trimmed = value?.trim() ?? '';
                                      if (trimmed.isEmpty) return null;
                                      return Validators.email(trimmed);
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: _RequiredFormField(
                                  label: 'Phone',
                                  hasError: _phoneError,
                                  errorText: _phoneError
                                      ? 'Phone is required'
                                      : null,
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Phone',
                                      hasError: _phoneError,
                                      borderless: true,
                                    ),
                                    onChanged: (_) {
                                      if (_phoneError) {
                                        setState(() => _phoneError = false);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Fax',
                                  child: TextFormField(
                                    controller: _faxController,
                                    keyboardType: TextInputType.phone,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Fax',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Mobile',
                                  child: TextFormField(
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Mobile',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Website',
                                  child: TextFormField(
                                    controller: _websiteController,
                                    keyboardType: TextInputType.url,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Website',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Lead Source',
                                  child: SaleGenericSelectDropdown(
                                    value: _leadSourceLabel ?? '-None-',
                                    hintText: '-None-',
                                    options: [
                                      '-None-',
                                      ...LeadSource.values.map((s) => s.label),
                                    ],
                                    onSelected: (label) => setState(() {
                                      _leadSourceLabel = label == '-None-'
                                          ? null
                                          : label;
                                    }),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Lead Status',
                                  child: SaleGenericSelectDropdown(
                                    value: _status.label,
                                    hintText: 'Status',
                                    options: LeadStatus.values
                                        .map((s) => s.label)
                                        .toList(),
                                    onSelected: (label) {
                                      setState(() {
                                        _status = LeadStatus.values.firstWhere(
                                          (s) => s.label == label,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Industry',
                                  child: SaleGenericSelectDropdown(
                                    value: _industry,
                                    hintText: '-None-',
                                    options: _industryOptions,
                                    onSelected: (value) =>
                                        setState(() => _industry = value),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'No. of Employees',
                                  child: TextFormField(
                                    controller: _employeesController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'No. of employees',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Annual Revenue',
                                  child: TextFormField(
                                    controller: _annualRevenueController,
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        buildSaleFieldDecoration(
                                          hint: 'Annual revenue',
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
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Rating',
                                  child: SaleGenericSelectDropdown(
                                    value: _rating,
                                    hintText: 'None',
                                    options: _ratingOptions,
                                    onSelected: (value) =>
                                        setState(() => _rating = value),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Email Opt Out',
                                  fixedHeight: false,
                                  child: SizedBox(
                                    height: FormSpacing.inputHeight,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                              value: _emailOptOut,
                                              onChanged: (value) => setState(
                                                () => _emailOptOut =
                                                    value ?? false,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          const Text(
                                            'Email Opt Out',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Secondary Email',
                                  child: TextFormField(
                                    controller: _secondaryEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Secondary email',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FormSpacing.row),
                          AppFormField(
                            label: 'Description',
                            fixedHeight: false,
                            child: TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: buildSaleFieldDecoration(
                                hint: 'Add a description for this lead',
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _AddLeadDialogHeader extends StatelessWidget {
  const _AddLeadDialogHeader({
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
                  'Create Lead',
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
                  'Create Lead',
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
      OutlinedButton(
        onPressed: onSaveAndNew,
        child: const Text('Save and New'),
      ),
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
            children: [
              Container(
                width: 3,
                height: FormSpacing.inputHeight,
                color: _requiredAccent,
              ),
              Expanded(
                child: Align(
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
