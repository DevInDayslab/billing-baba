import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:flutter/material.dart';

const _saveBlue = Color(0xFF1A62D6);

class CreateDealTaskInput {
  const CreateDealTaskInput({
    required this.subject,
    this.dueDate,
    this.priority = 'High',
    this.owner,
  });

  final String subject;
  final DateTime? dueDate;
  final String priority;
  final String? owner;
}

Future<CreateDealTaskInput?> showCreateDealTaskDialog(
  BuildContext context, {
  required String dealName,
}) {
  return showDialog<CreateDealTaskInput>(
    context: context,
    builder: (context) => CreateDealTaskDialog(dealName: dealName),
  );
}

class CreateDealTaskDialog extends StatefulWidget {
  const CreateDealTaskDialog({required this.dealName, super.key});

  final String dealName;

  @override
  State<CreateDealTaskDialog> createState() => _CreateDealTaskDialogState();
}

class _CreateDealTaskDialogState extends State<CreateDealTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _dueDateController = TextEditingController();
  String _priority = 'High';
  String _owner = 'Saksham Kochhar';
  bool _reminder = false;
  bool _repeat = false;

  static const _priorityOptions = ['High', 'Normal', 'Low'];
  static const _ownerOptions = [
    'Saksham Kochhar',
    'Priya Mehta',
    'Amit Verma',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dueDateController.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CreateDealTaskInput(
        subject: _subjectController.text.trim(),
        dueDate: _dueDateController.text.isEmpty
            ? null
            : DateTime.tryParse(_dueDateController.text),
        priority: _priority,
        owner: _owner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _subjectController,
                  decoration: buildSaleFieldDecoration(
                    hint: 'Subject',
                    suffixIcon: const Icon(
                      Icons.description_outlined,
                      size: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  onTap: _pickDueDate,
                  decoration: buildSaleFieldDecoration(
                    hint: 'Due Date (DD/MM/YYYY)',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SaleGenericSelectDropdown(
                  value: _priority,
                  options: _priorityOptions,
                  hintText: 'Priority',
                  onSelected: (value) => setState(() => _priority = value),
                ),
                const SizedBox(height: AppSpacing.md),
                SaleGenericSelectDropdown(
                  value: _owner,
                  options: _ownerOptions,
                  hintText: 'Owner',
                  onSelected: (value) => setState(() => _owner = value),
                ),
                const SizedBox(height: AppSpacing.md),
                _ToggleRow(
                  label: 'Reminder',
                  value: _reminder,
                  onChanged: (value) => setState(() => _reminder = value),
                ),
                _ToggleRow(
                  label: 'Repeat',
                  value: _repeat,
                  onChanged: (value) => setState(() => _repeat = value),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('More Fields'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: _saveBlue,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
