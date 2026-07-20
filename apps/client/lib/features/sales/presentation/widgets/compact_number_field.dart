import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/utils/sale_price_input.dart';
import 'package:billing_baba/features/sales/utils/sale_quantity_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact numeric field with stable controller lifecycle for table rows.
///
/// Keeps the raw text while focused so partial values like `1.` are not
/// overwritten by parsed parent state. Selects all text on focus for quick
/// replacement.
class CompactNumberField extends StatefulWidget {
  const CompactNumberField({
    required this.value,
    required this.onChanged,
    this.hintText,
    this.focusNode,
    this.selectAllOnFocus = true,
    this.borderless = false,
    this.integerOnly = false,
    this.useFieldBox = true,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? hintText;
  final FocusNode? focusNode;
  final bool selectAllOnFocus;
  final bool borderless;
  final bool integerOnly;
  final bool useFieldBox;

  @override
  State<CompactNumberField> createState() => CompactNumberFieldState();
}

class CompactNumberFieldState extends State<CompactNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(CompactNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      final formatted = _formatValue(widget.value);
      if (_controller.text != formatted) {
        _controller.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void requestFocusAndSelectAll() {
    _focusNode.requestFocus();
    _selectAll();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _selectAll();
    } else {
      _commitValue();
    }
  }

  void _selectAll() {
    if (!widget.selectAllOnFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focusNode.hasFocus) return;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commitValue() {
    final parsed = _parseText(_controller.text);
    if (parsed == null) {
      _controller.text = _formatValue(widget.value);
      return;
    }
    final formatted = _formatValue(parsed);
    if (_controller.text != formatted) {
      _controller.text = formatted;
    }
    if (parsed != widget.value) {
      widget.onChanged(parsed);
    }
  }

  double? _parseText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    if (widget.integerOnly) {
      final parsed = int.tryParse(trimmed);
      return parsed?.toDouble();
    }
    return double.tryParse(trimmed);
  }

  String _formatValue(double value) {
    if (widget.integerOnly) {
      return SaleQuantityInput.format(value);
    }
    return SalePriceInput.format(value);
  }

  void _handleChanged(String text) {
    final parsed = _parseText(text);
    if (parsed != null) {
      widget.onChanged(parsed);
      return;
    }
    if (text.trim().isEmpty) {
      widget.onChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: saleFieldTextStyle.copyWith(fontSize: 12, height: 1),
      textAlignVertical: TextAlignVertical.center,
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: true,
        borderless: widget.borderless,
      ),
      keyboardType: widget.integerOnly
          ? SaleQuantityInput.integerKeyboardType
          : SalePriceInput.keyboardType,
      inputFormatters: widget.integerOnly
          ? SaleQuantityInput.integerFormatters
          : SalePriceInput.formatters,
      onChanged: _handleChanged,
      onSubmitted: (_) => _commitValue(),
    );

    if (!widget.useFieldBox) return field;
    return SaleCompactFieldBox(child: field);
  }
}
