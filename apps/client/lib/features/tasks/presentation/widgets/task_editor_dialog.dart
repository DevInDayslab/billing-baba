import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _dialogMaxWidth = 400.0;

Future<TaskEditorResult?> showTaskEditorDialog(
  BuildContext context, {
  TaskModel? editTask,
  String? initialTitle,
}) {
  return showDialog<TaskEditorResult>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TaskEditorDialog(
        editTask: editTask,
        initialTitle: initialTitle,
      ),
    ),
  );
}

class TaskEditorResult {
  const TaskEditorResult({
    required this.title,
    this.description,
    this.reminderAt,
  });

  final String title;
  final String? description;
  final DateTime? reminderAt;
}

class TaskEditorDialog extends StatefulWidget {
  const TaskEditorDialog({this.editTask, this.initialTitle, super.key});

  final TaskModel? editTask;
  final String? initialTitle;

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _titleFocus = FocusNode();
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  String? _errorMessage;

  bool get _isEditing => widget.editTask != null;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    final task = widget.editTask;
    _titleController = TextEditingController(
      text: task?.title ?? widget.initialTitle ?? '',
    );
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    final reminder = task?.reminderAt;
    if (reminder != null) {
      _reminderDate = DateTime(reminder.year, reminder.month, reminder.day);
      if (reminder.hour != 0 || reminder.minute != 0) {
        _reminderTime = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  DateTime? get _combinedReminder {
    final date = _reminderDate;
    if (date == null) return null;
    final time = _reminderTime;
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Title is required');
      return;
    }
    Navigator.of(context).pop(
      TaskEditorResult(
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        reminderAt: _combinedReminder,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _reminderDate = picked);
  }

  Future<void> _pickTime() async {
    if (_reminderDate == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
  }

  void _clearReminder() {
    setState(() {
      _reminderDate = null;
      _reminderTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _DismissIntent(),
      },
      child: Actions(
        actions: {
          _DismissIntent: CallbackAction<_DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).pop();
              return null;
            },
          ),
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
          child: Material(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isEditing ? 'Edit Task' : 'Add Task',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Task Title', style: saleFieldLabelStyle),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: saleFieldTextStyle,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    onSubmitted: (_) => _save(),
                    decoration: buildSaleFieldDecoration(
                      hint: 'e.g., Call supplier',
                      hasError: hasError,
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: saleFieldErrorColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  const Text('Optional Notes', style: saleFieldLabelStyle),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _descriptionController,
                    style: saleFieldTextStyle,
                    maxLines: 2,
                    decoration: buildSaleFieldDecoration(
                      hint: 'Add a note',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Reminder Date', style: saleFieldLabelStyle),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDate,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(
                            _reminderDate == null
                                ? 'Optional'
                                : _dateFormat.format(_reminderDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _reminderDate == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (_reminderDate != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          onPressed: _clearReminder,
                          icon: const Icon(Icons.clear, size: 18),
                          color: AppColors.textSecondary,
                          tooltip: 'Clear reminder',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Reminder Time', style: saleFieldLabelStyle),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: _reminderDate == null ? null : _pickTime,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      _reminderTime == null
                          ? 'Optional'
                          : _reminderTime!.format(context),
                      style: TextStyle(
                        fontSize: 14,
                        color: _reminderTime == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissIntent extends Intent {
  const _DismissIntent();
}
