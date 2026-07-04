import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Gstr3bReportContent extends ConsumerStatefulWidget {
  const Gstr3bReportContent({super.key});

  @override
  ConsumerState<Gstr3bReportContent> createState() => _Gstr3bReportContentState();
}

class _Gstr3bReportContentState extends ConsumerState<Gstr3bReportContent> {
  late DateTime _fromMonth;
  late DateTime _toMonth;
  bool _considerNonTaxExempted = false;

  static final _monthFormat = DateFormat('MM/yyyy');

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
    final supplyRows = ref.watch(reportGstr3bProvider);

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
                    label: 'From Month/Year',
                    value: _monthFormat.format(_fromMonth),
                    onTap: () => _pickMonth(isFrom: true),
                  ),
                  _MonthField(
                    label: 'To Month/Year',
                    value: _monthFormat.format(_toMonth),
                    onTap: () => _pickMonth(isFrom: false),
                  ),
                  const ReportTextActionButton(
                    label: 'Excel Report',
                    icon: Icons.table_chart_outlined,
                  ),
                  const ReportTextActionButton(
                    label: 'Print',
                    icon: Icons.print_outlined,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'GSTR3 REPORT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _considerNonTaxExempted,
                                onChanged: (value) => setState(
                                  () =>
                                      _considerNonTaxExempted = value ?? false,
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
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    _SectionTitle(
                      title:
                          'Details of outward supplies and inward supplies '
                          'liable to reverse charge',
                    ),
                    _TaxSupplyTable(rows: supplyRows),
                    const Divider(height: 1, color: reportCardBorder),
                    _SectionTitle(
                      title:
                          '5. Details of inter-State supplies made to '
                          'unregistered persons, composition dealer and UIN holders',
                    ),
                    const _InterStateSuppliesTable(),
                    const Divider(height: 1, color: reportCardBorder),
                    const _SectionTitle(title: '3. Eligible ITC'),
                    const _ItcTable(),
                    const Divider(height: 1, color: reportCardBorder),
                    _SectionTitle(
                      title:
                          '4. Details of exempt, nil-rated and non-GST '
                          'inward supplies',
                    ),
                    const _ExemptSuppliesTable(),
                    const SizedBox(height: AppSpacing.md),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Gstr3bHeaderStyle {
  static const group = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

class _TaxSupplyTable extends StatelessWidget {
  const _TaxSupplyTable({required this.rows});

  final List<ReportGstr3bRow> rows;

  static const _natureWidth = 280.0;
  static const _valueWidth = 120.0;
  static const _cessWidth = 80.0;
  static const minWidth =
      _natureWidth + (_valueWidth * 4) + _cessWidth + 32;

  @override
  Widget build(BuildContext context) {
    return ReportSyncScrollTable(
      minWidth: minWidth,
      headerChildren: const [
        ReportAlignedHeaderCell(
          label: 'NATURE OF SUPPLIES',
          width: _natureWidth,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'TOTAL TAXABLE VALUE',
          width: _valueWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'INTEGRATED TAX',
          width: _valueWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'CENTRAL TAX',
          width: _valueWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'STATE/UT TAX',
          width: _valueWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'CESS',
          width: _cessWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          ReportAlignedRowStrip(
            index: i,
            child: ReportAlignedDataRow(
              cells: [
                ReportAlignedCell.fixed(
                  _natureWidth,
                  child: Text(rows[i].nature),
                ),
                ReportAlignedCell.fixed(
                  _valueWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(rows[i].taxableValue)),
                ),
                ReportAlignedCell.fixed(
                  _valueWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(rows[i].integratedTax)),
                ),
                ReportAlignedCell.fixed(
                  _valueWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(rows[i].centralTax)),
                ),
                ReportAlignedCell.fixed(
                  _valueWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(rows[i].stateTax)),
                ),
                ReportAlignedCell.fixed(
                  _cessWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(rows[i].cess)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InterStateSuppliesTable extends StatelessWidget {
  const _InterStateSuppliesTable();

  static const _placeWidth = 160.0;
  static const _valueWidth = 130.0;
  static const _groupWidth = _valueWidth * 2;
  static const _columnsWidth = _placeWidth + (_groupWidth * 3);
  static const _horizontalPadding = AppSpacing.md * 2;
  static const minWidth = _columnsWidth + _horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: minWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
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
                          const SizedBox(
                            width: _placeWidth,
                            child: ReportAlignedHeaderCell(
                              label: 'PLACE OF SUPPLY (STATE/UT)',
                              showFilter: false,
                            ),
                          ),
                          for (final label in [
                            'SUPPLIES TO UNREGISTERED PERSONS',
                            'SUPPLIES TO COMPOSITION DEALERS',
                            'SUPPLIES TO UIN HOLDERS',
                          ])
                            SizedBox(
                              width: _groupWidth,
                              child: ReportAlignedHeaderCell(
                                label: label,
                                showFilter: false,
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
                          const SizedBox(width: _placeWidth),
                          for (var i = 0; i < 3; i++) ...[
                            const ReportAlignedHeaderCell(
                              label: 'Taxable Value',
                              width: _valueWidth,
                              alignment: Alignment.centerRight,
                              showFilter: false,
                            ),
                            const ReportAlignedHeaderCell(
                              label: 'Integrated Tax',
                              width: _valueWidth,
                              alignment: Alignment.centerRight,
                              showFilter: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ReportAlignedRowStrip(
                index: 0,
                child: ReportAlignedDataRow(
                  cells: [
                    const ReportAlignedCell.fixed(
                      _placeWidth,
                      child: SizedBox.shrink(),
                    ),
                    for (var i = 0; i < 6; i++)
                      ReportAlignedCell.fixed(
                        _valueWidth,
                        alignment: Alignment.centerRight,
                        child: Text(formatReportCurrency(0)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItcTable extends StatelessWidget {
  const _ItcTable();

  static const _detailWidth = 360.0;
  static const _taxWidth = 120.0;
  static const _cessWidth = 80.0;
  static const minWidth = _detailWidth + (_taxWidth * 3) + _cessWidth + 32;

  @override
  Widget build(BuildContext context) {
    return ReportSyncScrollTable(
      minWidth: minWidth,
      headerChildren: const [
        ReportAlignedHeaderCell(
          label: 'DETAILS',
          width: _detailWidth,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'INTEGRATED TAX',
          width: _taxWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'CENTRAL TAX',
          width: _taxWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'STATE/UT TAX',
          width: _taxWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'CESS',
          width: _cessWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
      ],
      rows: [
        ..._ItcGroupRow.buildRows(
          title: '(A) ITC Available (whether in full or part)',
          items: const [
            '(1) Import of goods',
            '(2) Import of services',
            '(3) Inward supplies liable to reverse charge (other than 1 & 2 above)',
            '(4) Inward supplies from ISD',
            '(5) All other ITC',
          ],
          startIndex: 0,
          detailWidth: _detailWidth,
          taxWidth: _taxWidth,
          cessWidth: _cessWidth,
        ),
        ..._ItcGroupRow.buildRows(
          title: '(D) Ineligible ITC',
          items: const [
            '(1) As per section 17(5)',
            '(2) Others',
          ],
          startIndex: 5,
          detailWidth: _detailWidth,
          taxWidth: _taxWidth,
          cessWidth: _cessWidth,
        ),
      ],
    );
  }
}

class _ItcGroupRow {
  static List<Widget> buildRows({
    required String title,
    required List<String> items,
    required int startIndex,
    required double detailWidth,
    required double taxWidth,
    required double cessWidth,
  }) {
    return [
      DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: reportCardBorder)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: _Gstr3bHeaderStyle.group,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
      for (var i = 0; i < items.length; i++)
        ReportAlignedRowStrip(
          index: startIndex + i,
          child: ReportAlignedDataRow(
            cells: [
              ReportAlignedCell.fixed(detailWidth, child: Text(items[i])),
              ReportAlignedCell.fixed(
                taxWidth,
                alignment: Alignment.centerRight,
                child: Text(formatReportCurrency(0)),
              ),
              ReportAlignedCell.fixed(
                taxWidth,
                alignment: Alignment.centerRight,
                child: Text(formatReportCurrency(0)),
              ),
              ReportAlignedCell.fixed(
                taxWidth,
                alignment: Alignment.centerRight,
                child: Text(formatReportCurrency(0)),
              ),
              ReportAlignedCell.fixed(
                cessWidth,
                alignment: Alignment.centerRight,
                child: Text(formatReportCurrency(0)),
              ),
            ],
          ),
        ),
    ];
  }
}

class _ExemptSuppliesTable extends StatelessWidget {
  const _ExemptSuppliesTable();

  static const _natureWidth = 320.0;
  static const _valueWidth = 160.0;
  static const minWidth = _natureWidth + (_valueWidth * 2) + 32;

  @override
  Widget build(BuildContext context) {
    const rows = [
      'From a supplier under composition scheme, Exempt and Nil rated supply',
      'Non GST supply',
    ];

    return ReportSyncScrollTable(
      minWidth: minWidth,
      headerChildren: const [
        ReportAlignedHeaderCell(
          label: 'NATURE OF SUPPLIES',
          width: _natureWidth,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'INTER-STATE SUPPLIES',
          width: _valueWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
        ReportAlignedHeaderCell(
          label: 'INTRA-STATE SUPPLIES',
          width: _valueWidth,
          alignment: Alignment.centerRight,
          showFilter: false,
        ),
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          ReportAlignedRowStrip(
            index: i,
            child: ReportAlignedDataRow(
              cells: [
                ReportAlignedCell.fixed(_natureWidth, child: Text(rows[i])),
                ReportAlignedCell.fixed(
                  _valueWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(0)),
                ),
                ReportAlignedCell.fixed(
                  _valueWidth,
                  alignment: Alignment.centerRight,
                  child: Text(formatReportCurrency(0)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
