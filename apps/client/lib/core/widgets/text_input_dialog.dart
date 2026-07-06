import 'package:flutter/material.dart';

/// Shows a dialog with a single text field. Returns trimmed text, or null if
/// cancelled. The [TextEditingController] lives inside the dialog widget so it
/// is not disposed while the route exit animation is still running.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String hint = '',
  String initialValue = '',
  String confirmLabel = 'Save',
  String cancelLabel = 'Cancel',
  TextCapitalization textCapitalization = TextCapitalization.none,
  InputDecoration? decoration,
  TextStyle? textStyle,
  bool autofocus = true,
  bool allowEmpty = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _TextInputDialog(
      title: title,
      hint: hint,
      initialValue: initialValue,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      textCapitalization: textCapitalization,
      decoration: decoration,
      textStyle: textStyle,
      autofocus: autofocus,
      allowEmpty: allowEmpty,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.initialValue,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.textCapitalization,
    required this.autofocus,
    required this.allowEmpty,
    this.decoration,
    this.textStyle,
  });

  final String title;
  final String hint;
  final String initialValue;
  final String confirmLabel;
  final String cancelLabel;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool allowEmpty;
  final InputDecoration? decoration;
  final TextStyle? textStyle;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (!widget.allowEmpty && value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: widget.textStyle,
        decoration: widget.decoration ?? InputDecoration(hintText: widget.hint),
        textCapitalization: widget.textCapitalization,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Search-style prompt that can return an empty string (e.g. clear filters).
Future<String?> showTextSearchDialog(
  BuildContext context, {
  required String title,
  String hint = '',
  String initialValue = '',
  String searchLabel = 'Search',
  String clearLabel = 'Clear',
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _TextSearchDialog(
      title: title,
      hint: hint,
      initialValue: initialValue,
      searchLabel: searchLabel,
      clearLabel: clearLabel,
    ),
  );
}

class _TextSearchDialog extends StatefulWidget {
  const _TextSearchDialog({
    required this.title,
    required this.hint,
    required this.initialValue,
    required this.searchLabel,
    required this.clearLabel,
  });

  final String title;
  final String hint;
  final String initialValue;
  final String searchLabel;
  final String clearLabel;

  @override
  State<_TextSearchDialog> createState() => _TextSearchDialogState();
}

class _TextSearchDialogState extends State<_TextSearchDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(''),
          child: Text(widget.clearLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.searchLabel),
        ),
      ],
    );
  }
}
