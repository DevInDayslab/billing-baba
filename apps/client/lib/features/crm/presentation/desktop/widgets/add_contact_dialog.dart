import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _dialogMaxWidth = 960.0;
const _cardBorder = Color(0xFFE0E0E0);
const _saveRed = Color(0xFFE53935);
const _requiredAccent = Color(0xFFD32F2F);

const _salutationOptions = ['-None-', 'Mr.', 'Mrs.', 'Ms.', 'Dr.'];
const _ownerOptions = [
  '-None-',
  'Saksham Kochhar',
  'Priya Mehta',
  'Amit Verma',
];

class AddContactInput {
  const AddContactInput({
    required this.name,
    required this.phone,
    this.email,
    this.accountName,
    this.owner,
    this.salutation,
    this.firstName,
    this.lastName,
    this.title,
    this.description,
    this.leadSource,
    this.otherPhone,
    this.mobile,
    this.assistant,
    this.vendorName,
    this.department,
    this.homePhone,
    this.fax,
    this.dateOfBirth,
    this.asstPhone,
    this.emailOptOut = false,
  });

  final String name;
  final String phone;
  final String? email;
  final String? accountName;
  final String? owner;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final String? title;
  final String? description;
  final String? leadSource;
  final String? otherPhone;
  final String? mobile;
  final String? assistant;
  final String? vendorName;
  final String? department;
  final String? homePhone;
  final String? fax;
  final DateTime? dateOfBirth;
  final String? asstPhone;
  final bool emailOptOut;
}

Future<AddContactInput?> showAddContactDialog(
  BuildContext context, {
  ValueChanged<AddContactInput>? onSaveAndNew,
}) {
  return showDialog<AddContactInput>(
    context: context,
    builder: (context) => AddContactDialog(onSaveAndNew: onSaveAndNew),
  );
}

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({this.onSaveAndNew, super.key});

  final ValueChanged<AddContactInput>? onSaveAndNew;

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dobPickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otherPhoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _assistantController = TextEditingController();
  final _vendorController = TextEditingController();
  final _titleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _homePhoneController = TextEditingController();
  final _faxController = TextEditingController();
  final _asstPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dobDisplayController = TextEditingController();

  String _salutation = '-None-';
  String _owner = '-None-';
  String? _leadSourceLabel;
  DateTime? _dateOfBirth;
  bool _emailOptOut = false;

  bool _lastNameError = false;
  bool _phoneError = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _accountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otherPhoneController.dispose();
    _mobileController.dispose();
    _assistantController.dispose();
    _vendorController.dispose();
    _titleController.dispose();
    _departmentController.dispose();
    _homePhoneController.dispose();
    _faxController.dispose();
    _asstPhoneController.dispose();
    _descriptionController.dispose();
    _dobDisplayController.dispose();
    super.dispose();
  }

  String _buildContactName() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  String _resolvePhone() {
    for (final controller in [
      _phoneController,
      _mobileController,
      _otherPhoneController,
      _homePhoneController,
    ]) {
      final trimmed = controller.text.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  AddContactInput _buildInput() {
    final description = _descriptionController.text.trim();

    return AddContactInput(
      name: _buildContactName(),
      phone: _resolvePhone(),
      email: _nullable(_emailController.text),
      accountName: _nullable(_accountController.text),
      owner: _owner == '-None-' ? null : _owner,
      salutation: _salutation == '-None-' ? null : _salutation,
      firstName: _nullable(_firstNameController.text),
      lastName: _nullable(_lastNameController.text),
      title: _nullable(_titleController.text),
      description: description.isEmpty ? null : description,
      leadSource: _leadSourceLabel,
      otherPhone: _nullable(_otherPhoneController.text),
      mobile: _nullable(_mobileController.text),
      assistant: _nullable(_assistantController.text),
      vendorName: _nullable(_vendorController.text),
      department: _nullable(_departmentController.text),
      homePhone: _nullable(_homePhoneController.text),
      fax: _nullable(_faxController.text),
      dateOfBirth: _dateOfBirth,
      asstPhone: _nullable(_asstPhoneController.text),
      emailOptOut: _emailOptOut,
    );
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _validate() {
    final lastNameEmpty = _lastNameController.text.trim().isEmpty;
    final phoneEmpty = _resolvePhone().isEmpty;

    setState(() {
      _lastNameError = lastNameEmpty;
      _phoneError = phoneEmpty;
    });

    return !lastNameEmpty && !phoneEmpty;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _accountController.clear();
    _emailController.clear();
    _phoneController.clear();
    _otherPhoneController.clear();
    _mobileController.clear();
    _assistantController.clear();
    _vendorController.clear();
    _titleController.clear();
    _departmentController.clear();
    _homePhoneController.clear();
    _faxController.clear();
    _asstPhoneController.clear();
    _descriptionController.clear();
    _dobDisplayController.clear();
    setState(() {
      _salutation = '-None-';
      _owner = '-None-';
      _leadSourceLabel = null;
      _dateOfBirth = null;
      _emailOptOut = false;
      _lastNameError = false;
      _phoneError = false;
    });
  }

  void _updateDateOfBirth(DateTime date) {
    setState(() {
      _dateOfBirth = date;
      _dobDisplayController.text = DateFormat('dd/MM/yyyy').format(date);
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

  Widget _phoneField({
    required TextEditingController controller,
    required String hint,
    bool showError = false,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
      ],
      decoration: buildSaleFieldDecoration(
        hint: hint,
        hasError: showError,
        borderless: showError,
      ),
      onChanged: (_) {
        if (_phoneError) setState(() => _phoneError = false);
        onChanged?.call();
      },
    );
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
              _AddContactDialogHeader(
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
                      title: 'Contact Information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormGrid(
                            cells: [
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Contact Owner',
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
                                  label: 'Account Name',
                                  child: TextFormField(
                                    controller: _accountController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Account name',
                                      suffixIcon: const Icon(
                                        Icons.business_outlined,
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
                                  label: 'Vendor Name',
                                  child: TextFormField(
                                    controller: _vendorController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Vendor name',
                                      suffixIcon: const Icon(
                                        Icons.badge_outlined,
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
                                  label: 'Phone',
                                  hasError: _phoneError,
                                  errorText: _phoneError
                                      ? 'Provide at least one phone number'
                                      : null,
                                  child: _phoneField(
                                    controller: _phoneController,
                                    hint: 'Phone',
                                    showError: _phoneError,
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Department',
                                  child: TextFormField(
                                    controller: _departmentController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Department',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Other Phone',
                                  child: _phoneField(
                                    controller: _otherPhoneController,
                                    hint: 'Other phone',
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Home Phone',
                                  child: _phoneField(
                                    controller: _homePhoneController,
                                    hint: 'Home phone',
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Mobile',
                                  child: _phoneField(
                                    controller: _mobileController,
                                    hint: 'Mobile',
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Fax',
                                  child: _phoneField(
                                    controller: _faxController,
                                    hint: 'Fax',
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Assistant',
                                  child: TextFormField(
                                    controller: _assistantController,
                                    decoration: buildSaleFieldDecoration(
                                      hint: 'Assistant',
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Date of Birth',
                                  child: SaleSingleDatePickerAnchor(
                                    key: _dobPickerKey,
                                    selectedDate: _dateOfBirth,
                                    onDateSelected: _updateDateOfBirth,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _dobPickerKey.currentState?.toggle(),
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: _dobDisplayController,
                                          decoration: buildSaleFieldDecoration(
                                            hint: 'DD/MM/YYYY',
                                            suffixIcon: const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FormGridCell(
                                span: 6,
                                child: AppFormField(
                                  label: 'Asst Phone',
                                  child: _phoneField(
                                    controller: _asstPhoneController,
                                    hint: 'Asst phone',
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
                                hint: 'Add a description for this contact',
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

class _AddContactDialogHeader extends StatelessWidget {
  const _AddContactDialogHeader({
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
                  'Create Contact',
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
                  'Create Contact',
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
