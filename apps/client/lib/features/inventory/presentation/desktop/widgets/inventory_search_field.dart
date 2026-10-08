import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _searchFieldFontSize = 15.0;

class InventorySearchField extends StatefulWidget {
  const InventorySearchField({
    required this.hint,
    required this.onChanged,
    this.onDebouncedChanged,
    this.showSettings = false,
    this.onSettingsTap,
    this.onEscape,
    this.onArrowDown,
    this.onArrowUp,
    this.onEnter,
    this.debounceDuration = Duration.zero,
    this.initialValue = '',
    this.textStyle,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onDebouncedChanged;
  final bool showSettings;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onEscape;
  final VoidCallback? onArrowDown;
  final VoidCallback? onArrowUp;
  final VoidCallback? onEnter;
  final Duration debounceDuration;
  final String initialValue;
  final TextStyle? textStyle;

  @override
  State<InventorySearchField> createState() => _InventorySearchFieldState();
}

class _InventorySearchFieldState extends State<InventorySearchField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue.isNotEmpty;
    _controller.addListener(_syncHasText);
  }

  @override
  void didUpdateWidget(InventorySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_syncHasText)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText == _hasText) return;
    setState(() => _hasText = hasText);
  }

  void _handleChanged(String value) {
    widget.onChanged(value);
    if (widget.onDebouncedChanged == null) return;
    _debounce?.cancel();
    if (widget.debounceDuration == Duration.zero) {
      widget.onDebouncedChanged!(value);
      return;
    }
    _debounce = Timer(widget.debounceDuration, () {
      widget.onDebouncedChanged!(value);
    });
  }

  void _clearSearch() {
    if (_controller.text.isEmpty) return;
    _controller.clear();
    _handleChanged('');
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onEscape?.call();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        widget.onArrowDown?.call();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        widget.onArrowUp?.call();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        widget.onEnter?.call();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  Widget? _buildSuffixIcon() {
    if (_hasText) {
      return IconButton(
        onPressed: _clearSearch,
        icon: const Icon(Icons.close, size: 18),
        color: Colors.grey.shade600,
        tooltip: 'Clear search',
      );
    }

    if (widget.showSettings) {
      return IconButton(
        onPressed: widget.onSettingsTap,
        icon: const Icon(Icons.tune, size: 18),
        color: Colors.grey.shade600,
        tooltip: 'Filter',
      );
    }

    return Icon(Icons.search, size: 18, color: Colors.grey.shade500);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = (widget.textStyle ?? saleFieldTextStyle).copyWith(
      fontSize: _searchFieldFontSize,
      height: 1.25,
    );

    final decoration = buildSaleFieldDecoration(
      hint: widget.hint,
      suffixIcon: _buildSuffixIcon(),
      filled: true,
    ).copyWith(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: _searchFieldFontSize,
        height: 1.25,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          filled: true,
          fillColor: WidgetStateColor.resolveWith(
            (_) => AppColors.surface,
          ),
        ),
      ),
      child: SizedBox(
        height: 44,
        child: Focus(
          onKeyEvent: _handleKey,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _handleChanged,
            style: textStyle,
            decoration: decoration,
          ),
        ),
      ),
    );
  }
}
