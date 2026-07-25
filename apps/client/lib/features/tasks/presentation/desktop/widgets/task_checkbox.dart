import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TaskCheckbox extends StatelessWidget {
  const TaskCheckbox({
    required this.value,
    required this.onChanged,
    this.isOverdue = false,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isOverdue;

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final activeColor = value
        ? const Color(0xFF2E7D32)
        : (isOverdue ? AppColors.error : AppColors.textSecondary);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: value ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: activeColor, width: 1.5),
          ),
          child: AnimatedOpacity(
            duration: _duration,
            opacity: value ? 1 : 0,
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
