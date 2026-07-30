import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ExpandableGstinField extends StatefulWidget {
  const ExpandableGstinField({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;

  @override
  State<ExpandableGstinField> createState() => _ExpandableGstinFieldState();
}

class _ExpandableGstinFieldState extends State<ExpandableGstinField> {
  late final TextEditingController _controller;
  var _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _isExpanded = widget.initialValue?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: AppRadius.mdBorder,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Add GSTIN (optional)',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'GSTIN',
                    hintText: '22AAAAA0000A1Z5',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdBorder,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onChanged: (value) {
                    widget.onChanged(value.trim().isEmpty ? null : value.trim());
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
