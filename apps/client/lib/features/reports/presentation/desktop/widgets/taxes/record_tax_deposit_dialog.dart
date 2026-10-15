import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/payment_account_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showRecordTaxDepositDialog(
  BuildContext context, {
  required String kind,
  String? amount,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RecordTaxDepositDialog(kind: kind, amount: amount),
  );
}

class RecordTaxDepositDialog extends ConsumerStatefulWidget {
  const RecordTaxDepositDialog({
    required this.kind,
    this.amount,
    super.key,
  });

  final String kind;
  final String? amount;

  @override
  ConsumerState<RecordTaxDepositDialog> createState() =>
      _RecordTaxDepositDialogState();
}

class _RecordTaxDepositDialogState extends ConsumerState<RecordTaxDepositDialog> {
  final _bsrController = TextEditingController();
  final _serialController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _depositDate = DateTime.now();
  String? _bankAccountId;
  bool _saving = false;

  @override
  void dispose() {
    _bsrController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = widget.amount;
    if (amount == null || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select entries with a deposit amount first')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final client = await ref.read(apiClientProvider.future);
      await client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.reportsTaxDeposits,
        data: {
          'kind': widget.kind,
          'bsr_code': _bsrController.text.trim(),
          'challan_serial': _serialController.text.trim(),
          'deposit_date':
              '${_depositDate.year.toString().padLeft(4, '0')}-${_depositDate.month.toString().padLeft(2, '0')}-${_depositDate.day.toString().padLeft(2, '0')}',
          'amount': amount,
          if (_notesController.text.trim().isNotEmpty)
            'notes': _notesController.text.trim(),
          if (_bankAccountId != null && _bankAccountId!.isNotEmpty)
            'bank_account_id': _bankAccountId,
        },
      );
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to record deposit')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record ${widget.kind.toUpperCase()} deposit'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _bsrController,
              decoration: const InputDecoration(
                labelText: 'BSR code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Challan serial',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              title: const Text('Deposit date'),
              subtitle: Text(_depositDate.toLocal().toString().split(' ').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _depositDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _depositDate = picked);
              },
            ),
            if (widget.amount != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Amount: ${widget.amount}'),
            ],
            PaymentAccountField(
              paymentMode: 'bank_transfer',
              selectedAccountId: _bankAccountId,
              onChanged: (id) => setState(() => _bankAccountId = id),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
