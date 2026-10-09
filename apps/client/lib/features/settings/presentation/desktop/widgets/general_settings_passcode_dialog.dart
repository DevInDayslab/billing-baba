import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String?> showGeneralPasscodeSetupDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _GeneralPasscodeSetupDialog(),
  );
}

class _GeneralPasscodeSetupDialog extends StatefulWidget {
  const _GeneralPasscodeSetupDialog();

  @override
  State<_GeneralPasscodeSetupDialog> createState() =>
      _GeneralPasscodeSetupDialogState();
}

class _GeneralPasscodeSetupDialogState extends State<_GeneralPasscodeSetupDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      setState(() => _error = 'Enter a 4-digit passcode');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set app passcode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose a 4-digit passcode to protect app access.',
            style: AppTypography.inter(
              fontSize: AppTypography.bodySmallSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Passcode',
              errorText: _error,
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
