import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/models/sale_invoice_report_options.dart';
import 'package:flutter/material.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 20.0;

/// Shows the sale invoice Excel report options modal.
Future<SaleInvoiceReportOptions?> showSaleInvoiceReportOptionsDialog(
  BuildContext context,
) {
  return showDialog<SaleInvoiceReportOptions>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SaleInvoiceReportOptionsDialog(),
    ),
  );
}

class SaleInvoiceReportOptionsDialog extends StatefulWidget {
  const SaleInvoiceReportOptionsDialog({super.key});

  @override
  State<SaleInvoiceReportOptionsDialog> createState() =>
      _SaleInvoiceReportOptionsDialogState();
}

class _SaleInvoiceReportOptionsDialogState
    extends State<SaleInvoiceReportOptionsDialog> {
  SaleInvoiceReportOptions _options = const SaleInvoiceReportOptions();

  void _setOption({
    bool? includeDate,
    bool? includeInvoiceNo,
    bool? includePartyName,
    bool? includeTotal,
    bool? includePaymentType,
    bool? includeReceivedPaid,
    bool? includeBalanceDue,
    bool? includeItemDetails,
    bool? includeDescription,
    bool? includePaymentStatus,
    bool? includeOrderNumber,
    bool? includePartyPhone,
    bool? includePaymentBreakup,
    bool? includePartyGstin,
  }) {
    setState(() {
      _options = _options.copyWith(
        includeDate: includeDate,
        includeInvoiceNo: includeInvoiceNo,
        includePartyName: includePartyName,
        includeTotal: includeTotal,
        includePaymentType: includePaymentType,
        includeReceivedPaid: includeReceivedPaid,
        includeBalanceDue: includeBalanceDue,
        includeItemDetails: includeItemDetails,
        includeDescription: includeDescription,
        includePaymentStatus: includePaymentStatus,
        includeOrderNumber: includeOrderNumber,
        includePartyPhone: includePartyPhone,
        includePaymentBreakup: includePaymentBreakup,
        includePartyGstin: includePartyGstin,
      );
    });
  }

  void _handleGenerate() {
    if (!_options.hasAnySelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one report option')),
      );
      return;
    }
    Navigator.of(context).pop(_options);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _sectionGap,
                AppSpacing.md,
                _sectionGap,
                AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _OptionsColumn(
                      children: [
                        _ReportOptionCheckbox(
                          label: 'Date',
                          value: _options.includeDate,
                          onChanged: (value) =>
                              _setOption(includeDate: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Invoice No.',
                          value: _options.includeInvoiceNo,
                          onChanged: (value) =>
                              _setOption(includeInvoiceNo: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Party Name',
                          value: _options.includePartyName,
                          onChanged: (value) =>
                              _setOption(includePartyName: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Total',
                          value: _options.includeTotal,
                          onChanged: (value) =>
                              _setOption(includeTotal: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Payment Type',
                          value: _options.includePaymentType,
                          onChanged: (value) =>
                              _setOption(includePaymentType: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Received/Paid',
                          value: _options.includeReceivedPaid,
                          onChanged: (value) =>
                              _setOption(includeReceivedPaid: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Balance Due',
                          value: _options.includeBalanceDue,
                          onChanged: (value) =>
                              _setOption(includeBalanceDue: value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _OptionsColumn(
                      children: [
                        _ReportOptionCheckbox(
                          label: 'Item Details',
                          value: _options.includeItemDetails,
                          onChanged: (value) =>
                              _setOption(includeItemDetails: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Description',
                          value: _options.includeDescription,
                          onChanged: (value) =>
                              _setOption(includeDescription: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Payment Status',
                          value: _options.includePaymentStatus,
                          onChanged: (value) =>
                              _setOption(includePaymentStatus: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Order Number',
                          value: _options.includeOrderNumber,
                          onChanged: (value) =>
                              _setOption(includeOrderNumber: value),
                        ),
                        _ReportOptionCheckbox(
                          label: "Party's Phone No.",
                          value: _options.includePartyPhone,
                          onChanged: (value) =>
                              _setOption(includePartyPhone: value),
                        ),
                        _ReportOptionCheckbox(
                          label: 'Show Payment Breakup',
                          value: _options.includePaymentBreakup,
                          onChanged: (value) =>
                              _setOption(includePaymentBreakup: value),
                        ),
                        _ReportOptionCheckbox(
                          label: "Party's GSTIN",
                          value: _options.includePartyGstin,
                          onChanged: (value) =>
                              _setOption(includePartyGstin: value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            Padding(
              padding: const EdgeInsets.all(_sectionGap),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _handleGenerate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBorder,
                    ),
                  ),
                  child: const Text(
                    'Generate Report',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        _sectionGap,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          const Text(
            'Select Report Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _OptionsColumn extends StatelessWidget {
  const _OptionsColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          children[i],
        ],
      ],
    );
  }
}

class _ReportOptionCheckbox extends StatelessWidget {
  const _ReportOptionCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppRadius.smBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                activeColor: AppColors.error,
                side: const BorderSide(color: Color(0xFFBDBDBD)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
