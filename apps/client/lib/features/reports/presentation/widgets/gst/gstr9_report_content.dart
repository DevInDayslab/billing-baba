import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Gstr9ReportContent extends ConsumerStatefulWidget {
  const Gstr9ReportContent({super.key});

  @override
  ConsumerState<Gstr9ReportContent> createState() => _Gstr9ReportContentState();
}

class _Gstr9ReportContentState extends ConsumerState<Gstr9ReportContent> {
  static const _gstr9Border = Color(0xFFE2E8F0);

  late String _financialYear;
  bool _considerNonTaxExempted = false;

  static const _financialYearOptions = [
    '2021-2022',
    '2022-2023',
    '2023-2024',
    '2024-2025',
    '2025-2026',
    '2026-2027',
  ];

  @override
  void initState() {
    super.initState();
    _financialYear = _defaultFinancialYear();
  }

  static String _defaultFinancialYear() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final label = '$startYear-${startYear + 1}';
    return _financialYearOptions.contains(label)
        ? label
        : _financialYearOptions.last;
  }

  @override
  Widget build(BuildContext context) {
    final supplyRows = ref.watch(reportGstr9SupplyProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Text(
                    'Financial Year',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SaleFilterDropdown(
                    label: _financialYear,
                    options: _financialYearOptions,
                    selected: _financialYear,
                    onSelected: (value) =>
                        setState(() => _financialYear = value),
                  ),
                  const Spacer(),
                  const ReportTextActionButton(
                    label: 'Excel',
                    icon: Icons.table_chart_outlined,
                  ),
                  const ReportTextActionButton(
                    label: 'Print',
                    icon: Icons.print_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'GSTR9 REPORT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: _considerNonTaxExempted,
                          onChanged: (value) => setState(
                            () => _considerNonTaxExempted = value ?? false,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text(
                          'CONSIDER NON-TAX AS EXEMPTED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  _SectionBanner(title: 'Pt. I Basic Details'),
                  _BasicDetailsTable(
                    financialYear: _financialYear,
                    borderColor: _gstr9Border,
                  ),
                  _SectionBanner(
                    title:
                        'Pt. II Details Of Outward And Inward Supplies '
                        'Declared During The Financial Year',
                    trailing: '(Amount in Rupees in All Tables)',
                  ),
                  _OutwardSuppliesTable(
                    borderColor: _gstr9Border,
                    supplyRows: supplyRows,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBanner extends StatelessWidget {
  const _SectionBanner({
    required this.title,
    this.trailing,
  });

  final String title;
  final String? trailing;

  static const _primaryHeaderBg = Color(0xFF4A5568);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _primaryHeaderBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BasicDetailsTable extends StatelessWidget {
  const _BasicDetailsTable({
    required this.financialYear,
    required this.borderColor,
  });

  final String financialYear;
  final Color borderColor;

  static const _codeWidth = 48.0;
  static const _labelWidth = 180.0;
  static const _cellStyle = TextStyle(fontSize: 12, color: AppColors.textPrimary);

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('1', 'Financial Year', null),
      ('2', 'GSTIN', ''),
      ('3A', 'Legal Name', 'My Company'),
      ('3B', 'Trade Name (if any)', ''),
    ];

    return Table(
      border: TableBorder.all(color: borderColor),
      columnWidths: const {
        0: FixedColumnWidth(_codeWidth),
        1: FixedColumnWidth(_labelWidth),
        2: FlexColumnWidth(),
      },
      children: [
        for (final row in rows)
          TableRow(
            children: [
              _TableCell(
                Text(row.$1, style: _cellStyle, textAlign: TextAlign.center),
              ),
              _TableCell(Text(row.$2, style: _cellStyle)),
              _TableCell(
                Text(
                  row.$3 == null ? financialYear : row.$3!,
                  style: _cellStyle,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _OutwardSuppliesColumnLayout {
  static const codeWidth = 36.0;
  static const valueWidth = 90.0;
  static const minWidth = codeWidth + (valueWidth * 5) + 200;
}

class _OutwardSuppliesTable extends StatelessWidget {
  const _OutwardSuppliesTable({
    required this.borderColor,
    required this.supplyRows,
  });

  final Color borderColor;
  final List<ReportGstr9SupplyRow> supplyRows;

  static const _secondaryHeaderBg = Color(0xFFEDF2F7);
  static const _rowCodes = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth.isFinite
            ? math.max(
                constraints.maxWidth,
                _OutwardSuppliesColumnLayout.minWidth,
              )
            : _OutwardSuppliesColumnLayout.minWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ColoredBox(
                    color: _secondaryHeaderBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: _OutwardSuppliesColumnLayout.codeWidth,
                          ),
                          const Expanded(
                            child: ReportAlignedHeaderCell(
                              label: 'Nature of Supplies',
                              showFilter: false,
                            ),
                          ),
                          for (final label in [
                            'Taxable Value',
                            'Central Tax',
                            'State Tax / UT Tax',
                            'Integrated Tax',
                            'Cess',
                          ])
                            ReportAlignedHeaderCell(
                              label: label,
                              width: _OutwardSuppliesColumnLayout.valueWidth,
                              alignment: Alignment.center,
                              showFilter: false,
                            ),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _secondaryHeaderBg,
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: _OutwardSuppliesColumnLayout.codeWidth,
                          ),
                          const Expanded(
                            child: Text(
                              '4 Details of advances, inward and outward supplies on '
                              'which tax is payable as declared in returns filed during '
                              'the financial year',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          for (var i = 0; i < 5; i++)
                            SizedBox(
                              width: _OutwardSuppliesColumnLayout.valueWidth,
                            ),
                        ],
                      ),
                    ),
                  ),
                  for (var i = 0; i < supplyRows.length; i++)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: borderColor)),
                      ),
                      child: ReportAlignedDataRow(
                        cells: [
                          ReportAlignedCell.fixed(
                            _OutwardSuppliesColumnLayout.codeWidth,
                            alignment: Alignment.center,
                            child: Text(
                              i < _rowCodes.length ? _rowCodes[i] : '${i + 1}',
                            ),
                          ),
                          ReportAlignedCell.flex(
                            child: Text(supplyRows[i].label),
                          ),
                          ReportAlignedCell.fixed(
                            _OutwardSuppliesColumnLayout.valueWidth,
                            alignment: Alignment.center,
                            child: Text(
                              formatReportCurrency(supplyRows[i].taxableValue),
                            ),
                          ),
                          ReportAlignedCell.fixed(
                            _OutwardSuppliesColumnLayout.valueWidth,
                            alignment: Alignment.center,
                            child: Text(
                              formatReportCurrency(supplyRows[i].centralTax),
                            ),
                          ),
                          ReportAlignedCell.fixed(
                            _OutwardSuppliesColumnLayout.valueWidth,
                            alignment: Alignment.center,
                            child: Text(
                              formatReportCurrency(supplyRows[i].stateTax),
                            ),
                          ),
                          ReportAlignedCell.fixed(
                            _OutwardSuppliesColumnLayout.valueWidth,
                            alignment: Alignment.center,
                            child: Text(
                              formatReportCurrency(
                                supplyRows[i].integratedTax,
                              ),
                            ),
                          ),
                          ReportAlignedCell.fixed(
                            _OutwardSuppliesColumnLayout.valueWidth,
                            alignment: Alignment.center,
                            child: Text(
                              formatReportCurrency(supplyRows[i].cess),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}
