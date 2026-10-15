import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/application/gst_export_service.dart';
import 'package:billing_baba/features/reports/application/gst_report_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/gst/definitions/gst_report_definitions.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/gst_report_type.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/gst/gst_report_section_tabs.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GstReportScaffold extends ConsumerStatefulWidget {
  const GstReportScaffold({required this.type, super.key});

  final GstReportType type;

  @override
  ConsumerState<GstReportScaffold> createState() => _GstReportScaffoldState();
}

class _GstReportScaffoldState extends ConsumerState<GstReportScaffold> {
  int _tabIndex = 0;
  GstReportType? _lastType;

  @override
  void didUpdateWidget(covariant GstReportScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _tabIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lastType != widget.type) {
      _lastType = widget.type;
      _tabIndex = 0;
    }

    final definition = definitionFor(widget.type);
    final reportAsync = ref.watch(gstReportProvider(widget.type));

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(gstReportProvider(widget.type).notifier).refresh(),
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
                if (widget.type.isDiscontinuedFiling)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'GSTR-2 filing is discontinued on the GST portal. This register is for reconciliation only.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                if (envelope.warnings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _WarningsBanner(warnings: envelope.warnings),
                  ),
                const ReportFromToDateFilter(),
                if (widget.type.supportsNonTaxAsExempt) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const _NonTaxCheckbox(),
                ],
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReportXlsChip(
                          onTap: () => GstExportService.exportExcel(
                            context: context,
                            definition: definition,
                            envelope: envelope,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ReportPdfChip(
                          onTap: () => GstExportService.printReport(
                            context: context,
                            definition: definition,
                            envelope: envelope,
                            sectionKey: active.key,
                          ),
                        ),
                      ],
                    ),
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
                                        _gstReportColumnCell(
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
                                      _gstReportColumnCell(
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
    if (key.contains('value') ||
        key.contains('amount') ||
        key == 'igst' ||
        key == 'cgst' ||
        key == 'sgst') {
      return formatReportCurrency(double.tryParse(text) ?? 0);
    }
    return text;
  }
}

const _gstAmountColumnWidth = 112.0;

bool _gstColumnIsNumeric(String key) {
  return key.contains('value') ||
      key.contains('amount') ||
      key == 'igst' ||
      key == 'cgst' ||
      key == 'sgst' ||
      key == 'cess' ||
      key == 'itc_eligible' ||
      key == 'quantity' ||
      key == 'tax_rate' ||
      key == 'taxable_outward' ||
      key == 'tax_paid';
}

bool _gstColumnUsesFlexWidth(String key) {
  return key == 'nature' ||
      key == 'label' ||
      key == 'description' ||
      key == 'party_name';
}

double? _gstColumnFixedWidth(String key) {
  if (_gstColumnIsNumeric(key)) return _gstAmountColumnWidth;
  if (key == 'gstin') return 152;
  if (key.contains('date')) return 104;
  if (key == 'invoice_no' || key == 'bill_no') return 120;
  if (key == 'hsn') return 88;
  if (key == 'uqc') return 72;
  if (key == 'month') return 100;
  return null;
}

ReportSimpleCell _gstReportColumnCell({
  required GstReportColumnDef column,
  required String text,
  required TextStyle style,
}) {
  final key = column.key;
  final numeric = _gstColumnIsNumeric(key);
  final flexLabel = _gstColumnUsesFlexWidth(key);
  final alignment =
      numeric ? Alignment.centerRight : Alignment.centerLeft;

  final child = Text(
    text,
    style: style,
    textAlign: numeric ? TextAlign.right : TextAlign.left,
    softWrap: true,
    maxLines: flexLabel ? 4 : (numeric ? 1 : 2),
    overflow: flexLabel ? TextOverflow.clip : TextOverflow.ellipsis,
  );

  if (flexLabel) {
    return ReportSimpleCell(
      expanded: true,
      alignment: alignment,
      child: child,
    );
  }

  return ReportSimpleCell(
    width: _gstColumnFixedWidth(key) ?? 120,
    alignment: alignment,
    child: child,
  );
}

class _WarningsBanner extends StatelessWidget {
  const _WarningsBanner({required this.warnings});

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

class _NonTaxCheckbox extends ConsumerWidget {
  const _NonTaxCheckbox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: const Text(
        'Treat non-tax lines as exempt',
        style: TextStyle(fontSize: 13),
      ),
      value: filters.nonTaxAsExempt,
      onChanged: (value) {
        ref
            .read(reportFiltersProvider.notifier)
            .setNonTaxAsExempt(value ?? false);
      },
    );
  }
}
