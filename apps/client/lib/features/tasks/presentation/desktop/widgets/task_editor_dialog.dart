import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
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
    required this.category,
    this.reminderAt,
    this.deleted = false,
  });

  const TaskEditorResult.delete()
    : title = '',
      category = TaskCategory.general,
      reminderAt = null,
      deleted = true;

  final String title;
  final TaskCategory category;
  final DateTime? reminderAt;
  final bool deleted;
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
  final _titleFocus = FocusNode();
  late TaskCategory _category;
  DateTime? _dueAt;
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
    _category = task != null
        ? TaskCategoryResolver.resolve(task)
        : TaskCategory.general;
    _dueAt = task?.reminderAt;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
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
        category: _category,
        reminderAt: _dueAt,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _dueAt ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
      ),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null || !mounted) return;

    setState(() {
      final existing = _dueAt;
      _dueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        existing?.hour ?? now.hour,
        existing?.minute ?? now.minute,
      );
    });
  }

  void _clearDue() {
    setState(() => _dueAt = null);
  }

  Future<void> _confirmDelete() async {
    final task = widget.editTask;
    if (task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text(
          'Permanently delete "${task.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const TaskEditorResult.delete());
    }
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
                          _isEditing ? 'Edit Reminder' : 'Add Reminder',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          onPressed: _confirmDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          tooltip: 'Delete reminder',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
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
                  const Text('Title *', style: saleFieldLabelStyle),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: saleFieldTextStyle,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    decoration: buildSaleFieldDecoration(
                      hint: 'e.g., Collect payment from Sharma Traders',
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
                  const Text('Category', style: saleFieldLabelStyle),
                  const SizedBox(height: AppSpacing.sm),
                  InputDecorator(
                    decoration: buildSaleFieldDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskCategory>(
                        isExpanded: true,
                        value: _category,
                        items: TaskCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: category.iconBackgroundColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category.icon,
                                        size: 13,
                                        color: category.iconColor,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      category.label,
                                      style: saleFieldTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _category = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Due', style: saleFieldLabelStyle),
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
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _dueAt == null
                                      ? 'Select date'
                                      : _dateFormat.format(_dueAt!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _dueAt == null
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SaleTimeDropdown(
                          allowTyping: true,
                          value: _dueAt == null
                              ? null
                              : TimeOfDay(
                                  hour: _dueAt!.hour,
                                  minute: _dueAt!.minute,
                                ),
                          onSelected: (time) {
                            setState(() {
                              final now = DateTime.now();
                              final base =
                                  _dueAt ??
                                  DateTime(now.year, now.month, now.day);
                              _dueAt = DateTime(
                                base.year,
                                base.month,
                                base.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          },
                        ),
                      ),
                      if (_dueAt != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          onPressed: _clearDue,
                          icon: const Icon(Icons.clear, size: 18),
                          color: AppColors.textSecondary,
                          tooltip: 'Clear due date',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Save Reminder' : 'Add Reminder',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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

/// Applies a dialog result to the tasks store.
Future<void> applyTaskEditorResult({
  required TaskEditorResult result,
  required Tasks notifier,
  TaskModel? editTask,
}) async {
  if (result.deleted) {
    if (editTask != null) {
      await notifier.delete(editTask.id);
    }
    return;
  }

  if (editTask != null) {
    await notifier.updateTask(
      editTask.copyWith(
        title: result.title,
        category: result.category,
        reminderAt: result.reminderAt,
        clearReminderAt: result.reminderAt == null,
        updatedAt: DateTime.now(),
      ),
    );
  } else {
    await notifier.add(
      title: result.title,
      category: result.category,
      reminderAt: result.reminderAt,
    );
  }
}
