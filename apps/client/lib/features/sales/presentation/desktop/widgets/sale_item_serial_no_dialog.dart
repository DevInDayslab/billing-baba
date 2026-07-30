import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart'
    show SaleLineItem;
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Parses a stored serial string into individual serial numbers.
List<String> parseSaleItemSerialNos(String value) {
  if (value.trim().isEmpty) return const [];
  return value
      .split(RegExp(r'[,;\n]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Joins serial numbers for storage on [SaleLineItem.serialNo].
String joinSaleItemSerialNos(List<String> serials) =>
    serials.map((s) => s.trim()).where((s) => s.isNotEmpty).join(', ');

/// Opens the Sale Item serial-number entry dialog.
///
/// Returns the joined serial string on Save, or `null` if dismissed/closed.
Future<String?> showSaleItemSerialNoDialog(
  BuildContext context, {
  String initialSerials = '',
  double requiredQty = 0,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SaleItemSerialNoDialog(
        initialSerials: initialSerials,
        requiredQty: requiredQty,
      ),
    ),
  );
}

class SaleItemSerialNoDialog extends StatefulWidget {
  const SaleItemSerialNoDialog({
    this.initialSerials = '',
    this.requiredQty = 0,
    super.key,
  });

  final String initialSerials;
  final double requiredQty;

  @override
  State<SaleItemSerialNoDialog> createState() => _SaleItemSerialNoDialogState();
}

class _SaleItemSerialNoDialogState extends State<SaleItemSerialNoDialog> {
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  late final List<String> _serials;

  int get _requiredCount {
    if (widget.requiredQty <= 0) return 0;
    return widget.requiredQty.round();
  }

  @override
  void initState() {
    super.initState();
    _serials = List.of(parseSaleItemSerialNos(widget.initialSerials));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _addSerial() {
    final value = _inputController.text.trim();
    if (value.isEmpty) return;

    if (_requiredCount > 0 && _serials.length >= _requiredCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only $_requiredCount serial number${_requiredCount == 1 ? '' : 's'} '
            'required for this quantity.',
          ),
        ),
      );
      return;
    }

    final exists = _serials.any(
      (s) => s.toLowerCase() == value.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This serial number is already entered.')),
      );
      _inputController.clear();
      _inputFocus.requestFocus();
      return;
    }

    setState(() => _serials.add(value));
    _inputController.clear();
    _inputFocus.requestFocus();
  }

  void _removeSerial(int index) {
    setState(() => _serials.removeAt(index));
    _inputFocus.requestFocus();
  }

  void _save() {
    Navigator.of(context).pop(joinSaleItemSerialNos(_serials));
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      child: SizedBox(
        width: 520,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: saleFieldBorderColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Enter Serial No.:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_serials.length}/$_requiredCount Entered',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          focusNode: _inputFocus,
                          style: saleFieldTextStyle,
                          textInputAction: TextInputAction.done,
                          decoration: buildSaleFieldDecoration(
                            hint: 'Enter/Scan',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
                          ],
                          onSubmitted: (_) => _addSerial(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: FilledButton(
                          onPressed: _addSerial,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Icon(Icons.check, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _buildSerialList()),
            const Divider(height: 1, color: saleFieldBorderColor),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _close,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: saleFieldBorderColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Sale Item - Serial No.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _close,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildSerialList() {
    if (_serials.isEmpty) {
      return const SizedBox.expand();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: _serials.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final serial = _serials[index];
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: saleFieldBorderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  serial,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeSerial(index),
                icon: const Icon(Icons.close, size: 16),
                color: AppColors.textSecondary,
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        );
      },
    );
  }
}
