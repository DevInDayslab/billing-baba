import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact numeric field with stable controller lifecycle for table rows.
class CompactNumberField extends StatefulWidget {
  const CompactNumberField({
    required this.value,
    required this.onChanged,
    this.hintText,
    this.focusNode,
    this.selectAllOnFocus = true,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? hintText;
  final FocusNode? focusNode;
  final bool selectAllOnFocus;

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
    final parsed = double.tryParse(_controller.text.trim());
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

  String _formatValue(double value) {
    if (value == 0) return '';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (text) {
        final parsed = double.tryParse(text.trim());
        if (parsed != null) {
          widget.onChanged(parsed);
        } else if (text.trim().isEmpty) {
          widget.onChanged(0);
        }
      },
      onSubmitted: (_) => _commitValue(),
    );
  }
}
