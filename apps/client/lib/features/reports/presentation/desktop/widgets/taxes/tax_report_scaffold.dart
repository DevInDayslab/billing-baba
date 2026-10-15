import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/export/definition_report_export_service.dart';
import 'package:billing_baba/features/reports/application/tax_report_provider.dart';
import 'package:billing_baba/features/reports/gst/definitions/gst_report_definitions.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/tax_report_kind.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/gst/gst_report_section_tabs.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_envelope_column_helpers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/taxes/record_tax_deposit_dialog.dart';
import 'package:billing_baba/features/reports/tax/definitions/tax_report_definitions.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxReportScaffold extends ConsumerStatefulWidget {
  const TaxReportScaffold({required this.kind, super.key});

  final TaxReportKind kind;

  @override
  ConsumerState<TaxReportScaffold> createState() => _TaxReportScaffoldState();
}

class _TaxReportScaffoldState extends ConsumerState<TaxReportScaffold> {
  int _tabIndex = 0;
  TaxReportKind? _lastKind;

  @override
  Widget build(BuildContext context) {
    if (_lastKind != widget.kind) {
      _lastKind = widget.kind;
      _tabIndex = 0;
    }

    final definition = definitionForTaxReport(widget.kind);
    final reportAsync = ref.watch(taxReportProvider(widget.kind));

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(taxReportProvider(widget.kind).notifier).refresh(),
      data: (envelope) {
        final sections = envelope.sections.isNotEmpty
            ? envelope.sections
            : definition.sections
                  .map(
                    (s) => GstReportSectionDto(
                      key: s.key,
                      title: s.title,
                      rows: const [],
                    ),
                  )
                  .toList();
        final safeIndex = _tabIndex.clamp(0, sections.length - 1);
        final active = sections[safeIndex];
        final sectionDef =
            definition.sectionForKey(active.key) ?? definition.sections.first;
        final columns = _resolveColumns(sectionDef, active);
        final sectionLabels = sections
            .map(
              (s) => definition.sectionForKey(s.key)?.title ?? s.title,
            )
            .toList();
        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (envelope.warnings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _TaxWarningsBanner(warnings: envelope.warnings),
                  ),
                const ReportFromToDateFilter(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  definition.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GstReportSectionTabs(
                        sections: sectionLabels,
                        selectedIndex: safeIndex,
                        onSelected: (index) =>
                            setState(() => _tabIndex = index),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ReportXlsChip(
                      onTap: () => DefinitionReportExportService.exportExcel(
                        context: context,
                        definition: definition,
                        envelope: envelope,
                      ),
                    ),
                    if (widget.kind == TaxReportKind.tdsPayable ||
                        widget.kind == TaxReportKind.form27eq) ...[
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final deposited = await showRecordTaxDepositDialog(
                            context,
                            kind: widget.kind == TaxReportKind.form27eq
                                ? 'tcs'
                                : 'tds',
                            amount: envelope.totals['deposit_amount']
                                ?.toString(),
                          );
                          if (deposited == true) {
                            await ref
                                .read(taxReportProvider(widget.kind).notifier)
                                .refresh();
                          }
                        },
                        icon: const Icon(Icons.account_balance, size: 18),
                        label: const Text('Record deposit'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ReportCard(
                    child: active.rows.isEmpty
                        ? const Center(
                            child: Text(
                              'No data for this period',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ReportTableArea(
                            child: ListView.builder(
                              itemCount: active.rows.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return ReportSimpleDataRow(
                                    cells: [
                                      for (final column in columns)
                                        reportEnvelopeColumnCell(
                                          column: column,
                                          text: column.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  );
                                }
                                final row = active.rows[index - 1];
                                return ReportSimpleDataRow(
                                  cells: [
                                    for (final column in columns)
                                      reportEnvelopeColumnCell(
                                        column: column,
                                        text: _formatCell(
                                          column.key,
                                          row[column.key],
                                        ),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<GstReportColumnDef> _resolveColumns(
    GstReportSectionDef sectionDef,
    GstReportSectionDto section,
  ) {
    if (section.rows.isEmpty) return sectionDef.columns;
    final keys = section.rows.first.keys.toSet();
    final ordered =
        sectionDef.columns.where((c) => keys.contains(c.key)).toList();
    if (ordered.isNotEmpty) return ordered;
    return section.rows.first.keys
        .map((k) => GstReportColumnDef(k, k))
        .toList();
  }

  String _formatCell(String key, Object? value) {
    if (value == null) return '-';
    final text = value.toString();
    if (text.isEmpty) return '-';
    if (key.contains('date')) {
      final parsed = DateTime.tryParse(text);
      if (parsed != null) return formatReportDate(parsed);
    }
    if (reportEnvelopeColumnIsNumeric(key)) {
      return formatReportCurrency(double.tryParse(text) ?? 0);
    }
    return text;
  }
}

class _TaxWarningsBanner extends StatelessWidget {
  const _TaxWarningsBanner({required this.warnings});

  final List<GstReportWarningDto> warnings;

  @override
  Widget build(BuildContext context) {
    final total = warnings.fold<int>(0, (sum, w) => sum + w.count);
    return Material(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Color(0xFFF57C00),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '$total data quality warning(s) for this report.',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
