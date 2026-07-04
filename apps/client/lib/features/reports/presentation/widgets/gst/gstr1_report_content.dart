import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Gstr1ReportContent extends ConsumerStatefulWidget {
  const Gstr1ReportContent({super.key});

  @override
  ConsumerState<Gstr1ReportContent> createState() => _Gstr1ReportContentState();
}

class _Gstr1ReportContentState extends ConsumerState<Gstr1ReportContent> {
  late DateTime _fromMonth;
  late DateTime _toMonth;
  String _activeTab = 'Sale';
  bool _considerNonTaxExempted = false;

  static final _monthFormat = DateFormat('MM/yyyy');
  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF757575),
    letterSpacing: 0.4,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromMonth = DateTime(now.year, now.month);
    _toMonth = DateTime(now.year, now.month);
  }

  Future<void> _pickMonth({required bool isFrom}) async {
    final initial = isFrom ? _fromMonth : _toMonth;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final month = DateTime(picked.year, picked.month);
      if (isFrom) {
        _fromMonth = month;
      } else {
        _toMonth = month;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportGstr1SaleProvider);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MonthField(
                    label: 'From:',
                    value: _monthFormat.format(_fromMonth),
                    onTap: () => _pickMonth(isFrom: true),
                  ),
                  _MonthField(
                    label: 'To:',
                    value: _monthFormat.format(_toMonth),
                    onTap: () => _pickMonth(isFrom: false),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _considerNonTaxExempted,
                        onChanged: (value) => setState(
                          () => _considerNonTaxExempted = value ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Consider non-tax as exempted',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _GstrTabSwitcher(
              activeTab: _activeTab,
              onChanged: (tab) => setState(() => _activeTab = tab),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: rows.isEmpty
                          ? const Center(
                              child: Text(
                                'No data to display for the selected period.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final tableWidth = constraints.maxWidth.isFinite
                                    ? math.max(
                                        constraints.maxWidth,
                                        _Gstr1ColumnLayout.minWidth,
                                      )
                                    : _Gstr1ColumnLayout.minWidth;

                                return SingleChildScrollView(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: tableWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _Gstr1TableHeader(
                                            headerStyle: _headerStyle,
                                          ),
                                          for (var i = 0; i < rows.length; i++)
                                            ReportAlignedRowStrip(
                                              index: i,
                                              child: _Gstr1DataRow(
                                                index: i + 1,
                                                row: rows[i],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Gstr1ColumnLayout {
  static const indexWidth = 36.0;
  static const gstinWidth = 120.0;
  static const partyWidth = 120.0;
  static const invoiceNoWidth = 100.0;
  static const dateWidth = 90.0;
  static const valueWidth = 90.0;
  static const taxRateWidth = 80.0;
  static const cessWidth = 80.0;
  static const taxableWidth = 100.0;
  static const integratedWidth = 110.0;

  static const invoiceDetailsWidth =
      invoiceNoWidth + dateWidth + valueWidth + taxRateWidth;

  static const minWidth = indexWidth +
      gstinWidth +
      partyWidth +
      invoiceNoWidth +
      dateWidth +
      valueWidth +
      taxRateWidth +
      cessWidth +
      taxableWidth +
      integratedWidth;
}

class _Gstr1DataRow extends StatelessWidget {
  const _Gstr1DataRow({required this.index, required this.row});

  final int index;
  final ReportGstrRow row;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(indexWidth, child: Text('$index')),
        ReportAlignedCell.fixed(gstinWidth, child: Text(row.gstin)),
        ReportAlignedCell.fixed(partyWidth, child: Text(row.partyName)),
        ReportAlignedCell.fixed(invoiceNoWidth, child: Text(row.invoiceNo)),
        ReportAlignedCell.fixed(
          dateWidth,
          child: Text(formatReportDate(row.date)),
        ),
        ReportAlignedCell.fixed(
          valueWidth,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(row.value)),
        ),
        ReportAlignedCell.fixed(
          taxRateWidth,
          alignment: Alignment.centerRight,
          child: Text('${row.taxRate}%'),
        ),
        ReportAlignedCell.fixed(
          cessWidth,
          alignment: Alignment.centerRight,
          child: Text(row.cessRate > 0 ? '${row.cessRate}%' : '-'),
        ),
        ReportAlignedCell.fixed(
          taxableWidth,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(row.taxableValue)),
        ),
        ReportAlignedCell.fixed(
          integratedWidth,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(row.integratedTax)),
        ),
      ],
    );
  }

  static const indexWidth = _Gstr1ColumnLayout.indexWidth;
  static const gstinWidth = _Gstr1ColumnLayout.gstinWidth;
  static const partyWidth = _Gstr1ColumnLayout.partyWidth;
  static const invoiceNoWidth = _Gstr1ColumnLayout.invoiceNoWidth;
  static const dateWidth = _Gstr1ColumnLayout.dateWidth;
  static const valueWidth = _Gstr1ColumnLayout.valueWidth;
  static const taxRateWidth = _Gstr1ColumnLayout.taxRateWidth;
  static const cessWidth = _Gstr1ColumnLayout.cessWidth;
  static const taxableWidth = _Gstr1ColumnLayout.taxableWidth;
  static const integratedWidth = _Gstr1ColumnLayout.integratedWidth;
}

class _MonthField extends StatelessWidget {
  const _MonthField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: reportCardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GstrTabSwitcher extends StatelessWidget {
  const _GstrTabSwitcher({
    required this.activeTab,
    required this.onChanged,
  });

  final String activeTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: reportCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'Sale',
            selected: activeTab == 'Sale',
            onTap: () => onChanged('Sale'),
          ),
          _TabButton(
            label: 'Sale Return',
            selected: activeTab == 'Sale Return',
            onTap: () => onChanged('Sale Return'),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      elevation: selected ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Gstr1TableHeader extends StatelessWidget {
  const _Gstr1TableHeader({required this.headerStyle});

  final TextStyle headerStyle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: reportTableHeaderBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _Gstr1ColumnLayout.indexWidth,
                  child: Text('#', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.gstinWidth,
                  child: Text('GSTIN/UIN', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.partyWidth,
                  child: Text('Party Name', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.invoiceDetailsWidth,
                  child: Center(
                    child: Text('Invoice Details', style: headerStyle),
                  ),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.cessWidth,
                  child: Text('Cess Rate', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.taxableWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Taxable Value', style: headerStyle),
                  ),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.integratedWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Integrated Tax', style: headerStyle),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: reportCardBorder),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox(width: _Gstr1ColumnLayout.indexWidth),
                SizedBox(width: _Gstr1ColumnLayout.gstinWidth),
                SizedBox(width: _Gstr1ColumnLayout.partyWidth),
                SizedBox(
                  width: _Gstr1ColumnLayout.invoiceNoWidth,
                  child: Text('Invoice No.', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.dateWidth,
                  child: Text('Date', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.valueWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Value (₹)', style: headerStyle),
                  ),
                ),
                SizedBox(
                  width: _Gstr1ColumnLayout.taxRateWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Tax Rate', style: headerStyle),
                  ),
                ),
                SizedBox(width: _Gstr1ColumnLayout.cessWidth),
                SizedBox(width: _Gstr1ColumnLayout.taxableWidth),
                SizedBox(width: _Gstr1ColumnLayout.integratedWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
