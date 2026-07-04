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

class Gstr2ReportContent extends ConsumerStatefulWidget {
  const Gstr2ReportContent({super.key});

  @override
  ConsumerState<Gstr2ReportContent> createState() => _Gstr2ReportContentState();
}

class _Gstr2ReportContentState extends ConsumerState<Gstr2ReportContent> {
  late DateTime _fromMonth;
  late DateTime _toMonth;
  String _activeTab = 'Purchase';
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
    final rows = ref.watch(reportGstr2PurchaseProvider);

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
                                        _Gstr2ColumnLayout.minWidth,
                                      )
                                    : _Gstr2ColumnLayout.minWidth;

                                return SingleChildScrollView(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: tableWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _Gstr2TableHeader(
                                            headerStyle: _headerStyle,
                                          ),
                                          for (var i = 0; i < rows.length; i++)
                                            ReportAlignedRowStrip(
                                              index: i,
                                              child: _Gstr2DataRow(
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

class _Gstr2ColumnLayout {
  static const indexWidth = 36.0;
  static const gstinWidth = 120.0;
  static const partyWidth = 120.0;
  static const billNoWidth = 90.0;
  static const dateWidth = 90.0;
  static const valueWidth = 90.0;
  static const taxRateWidth = 80.0;
  static const cessWidth = 80.0;
  static const taxableWidth = 110.0;
  static const integratedWidth = 110.0;
  static const integratedTaxBg = Color(0xFFE8F5E9);

  static const billDetailsWidth =
      billNoWidth + dateWidth + valueWidth + taxRateWidth + cessWidth;

  static const minWidth = indexWidth +
      gstinWidth +
      partyWidth +
      billNoWidth +
      dateWidth +
      valueWidth +
      taxRateWidth +
      cessWidth +
      taxableWidth +
      integratedWidth;
}

class _Gstr2DataRow extends StatelessWidget {
  const _Gstr2DataRow({required this.index, required this.row});

  final int index;
  final ReportGstrRow row;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(indexWidth, child: Text('$index')),
        ReportAlignedCell.fixed(gstinWidth, child: Text(row.gstin)),
        ReportAlignedCell.fixed(partyWidth, child: Text(row.partyName)),
        ReportAlignedCell.fixed(billNoWidth, child: Text(row.invoiceNo)),
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
          child: ColoredBox(
            color: _Gstr2ColumnLayout.integratedTaxBg,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(formatReportCurrency(row.integratedTax)),
            ),
          ),
        ),
      ],
    );
  }

  static const indexWidth = _Gstr2ColumnLayout.indexWidth;
  static const gstinWidth = _Gstr2ColumnLayout.gstinWidth;
  static const partyWidth = _Gstr2ColumnLayout.partyWidth;
  static const billNoWidth = _Gstr2ColumnLayout.billNoWidth;
  static const dateWidth = _Gstr2ColumnLayout.dateWidth;
  static const valueWidth = _Gstr2ColumnLayout.valueWidth;
  static const taxRateWidth = _Gstr2ColumnLayout.taxRateWidth;
  static const cessWidth = _Gstr2ColumnLayout.cessWidth;
  static const taxableWidth = _Gstr2ColumnLayout.taxableWidth;
  static const integratedWidth = _Gstr2ColumnLayout.integratedWidth;
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
            label: 'Purchase',
            selected: activeTab == 'Purchase',
            onTap: () => onChanged('Purchase'),
          ),
          _TabButton(
            label: 'Purchase Return',
            selected: activeTab == 'Purchase Return',
            onTap: () => onChanged('Purchase Return'),
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

class _Gstr2TableHeader extends StatelessWidget {
  const _Gstr2TableHeader({required this.headerStyle});

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
                  width: _Gstr2ColumnLayout.indexWidth,
                  child: Text('#', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.gstinWidth,
                  child: Text('GSTIN/UIN', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.partyWidth,
                  child: Text('Party Name', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.billDetailsWidth,
                  child: Center(
                    child: Text('Bill Details', style: headerStyle),
                  ),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.taxableWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Taxable Value', style: headerStyle),
                  ),
                ),
                ColoredBox(
                  color: _Gstr2ColumnLayout.integratedTaxBg,
                  child: SizedBox(
                    width: _Gstr2ColumnLayout.integratedWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('Integrated Tax', style: headerStyle),
                      ),
                    ),
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
                SizedBox(width: _Gstr2ColumnLayout.indexWidth),
                SizedBox(width: _Gstr2ColumnLayout.gstinWidth),
                SizedBox(width: _Gstr2ColumnLayout.partyWidth),
                SizedBox(
                  width: _Gstr2ColumnLayout.billNoWidth,
                  child: Text('Bill No.', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.dateWidth,
                  child: Text('Date', style: headerStyle),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.valueWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Value (₹)', style: headerStyle),
                  ),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.taxRateWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Tax Rate', style: headerStyle),
                  ),
                ),
                SizedBox(
                  width: _Gstr2ColumnLayout.cessWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Cess Rate', style: headerStyle),
                  ),
                ),
                SizedBox(width: _Gstr2ColumnLayout.taxableWidth),
                ColoredBox(
                  color: _Gstr2ColumnLayout.integratedTaxBg,
                  child: SizedBox(width: _Gstr2ColumnLayout.integratedWidth),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
