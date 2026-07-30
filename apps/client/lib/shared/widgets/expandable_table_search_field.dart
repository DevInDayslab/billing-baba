import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact search control for table toolbars — icon by default, expands inline on tap.
class ExpandableTableSearchField extends StatefulWidget {
  const ExpandableTableSearchField({
    required this.hint,
    required this.onQueryChanged,
    this.initialQuery = '',
    this.expandedWidth = 220,
    super.key,
  });

  final String hint;
  final String initialQuery;
  final ValueChanged<String> onQueryChanged;
  final double expandedWidth;

  @override
  State<ExpandableTableSearchField> createState() =>
      _ExpandableTableSearchFieldState();
}

class _ExpandableTableSearchFieldState
    extends State<ExpandableTableSearchField> {
  static const _borderColor = Color(0xFFE0E0E0);
  static const _focusedBorderColor = Color(0xFF90CAF9);

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _expanded = widget.initialQuery.isNotEmpty;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _controller.text.isEmpty && _expanded) {
      setState(() => _expanded = false);
    }
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onQueryChanged(value);
    });
  }

  InputDecoration _fieldDecoration() {
    final borderRadius = BorderRadius.circular(20);

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 13,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      prefixIcon: Icon(
        Icons.search,
        size: 18,
        color: Colors.grey.shade500,
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _focusedBorderColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerRight,
      child: _expanded
          ? SizedBox(
              width: widget.expandedWidth,
              height: 36,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: _fieldDecoration(),
              ),
            )
          : IconButton(
              onPressed: _expand,
              icon: const Icon(Icons.search, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Search',
            ),
    );
  }
}
