import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_additional_phone_detail.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Prompts for an extra mobile number and optional description label.
Future<PartyAdditionalPhoneDetail?> showAddPartyAdditionalPhoneDialog(
  BuildContext context, {
  PartyAdditionalPhoneDetail? initial,
}) {
  return showDialog<PartyAdditionalPhoneDetail>(
    context: context,
    builder: (dialogContext) => _AddPartyAdditionalPhoneDialog(initial: initial),
  );
}

class _AddPartyAdditionalPhoneDialog extends StatefulWidget {
  const _AddPartyAdditionalPhoneDialog({this.initial});

  final PartyAdditionalPhoneDetail? initial;

  @override
  State<_AddPartyAdditionalPhoneDialog> createState() =>
      _AddPartyAdditionalPhoneDialogState();
}

class _AddPartyAdditionalPhoneDialogState
    extends State<_AddPartyAdditionalPhoneDialog> {
  late final TextEditingController _phoneController;
  late final TextEditingController _labelController;
  String? _phoneError;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initial?.phone ?? '');
    _labelController = TextEditingController(text: widget.initial?.label ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    final phoneError = Validators.phone(phone);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      return;
    }

    Navigator.of(context).pop(
      PartyAdditionalPhoneDetail(
        phone: phone,
        label: _labelController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      title: Text(
        _isEdit ? 'Edit number' : 'Add another number',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add a secondary contact number with an optional note.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textSecondary.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SaleTextField(
              controller: _labelController,
              hint: 'Description (e.g. WhatsApp, Office)',
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            SaleTextField(
              controller: _phoneController,
              hint: 'Mobile number *',
              hasError: _phoneError != null,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
            ),
            if (_phoneError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text(
                  _phoneError!,
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(_isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
