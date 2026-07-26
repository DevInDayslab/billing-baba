import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/export_actions.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_pdf_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Optional header metadata shown above the report preview body.
class ReportPreviewMeta {
  const ReportPreviewMeta({
    this.party,
    this.invoiceDate,
    this.invoiceNumber,
  });

  final String? party;
  final String? invoiceDate;
  final String? invoiceNumber;

  bool get hasValues =>
      (party?.isNotEmpty ?? false) ||
      (invoiceDate?.isNotEmpty ?? false) ||
      (invoiceNumber?.isNotEmpty ?? false);
}

enum _ReportPreviewTab { table, pdf }

/// Opens a large modal with a formatted table and embedded PDF preview.
Future<void> showReportPreviewDialog({
  required BuildContext context,
  required String title,
  required String filenameBase,
  required List<String> headers,
  required List<List<String>> rows,
  ReportPreviewMeta? meta,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => ReportPreviewDialog(
      title: title,
      filenameBase: filenameBase,
      headers: headers,
      rows: rows,
      meta: meta,
    ),
  );
}

class ReportPreviewDialog extends StatefulWidget {
  const ReportPreviewDialog({
    required this.title,
    required this.filenameBase,
    required this.headers,
    required this.rows,
    this.meta,
    super.key,
  });

  final String title;
  final String filenameBase;
  final List<String> headers;
  final List<List<String>> rows;
  final ReportPreviewMeta? meta;

  @override
  State<ReportPreviewDialog> createState() => _ReportPreviewDialogState();
}

class _ReportPreviewDialogState extends State<ReportPreviewDialog> {
  _ReportPreviewTab _tab = _ReportPreviewTab.table;
  Uint8List? _cachedPdfBytes;
  final _printOutput = PrintOutputService();

  Future<Uint8List> _buildPdfBytes() async {
    if (_cachedPdfBytes != null) {
      return _cachedPdfBytes!;
    }

    final bytes = await ReportPdfBuilder.build(
      title: widget.title,
      headers: widget.headers,
      rows: widget.rows,
      meta: widget.meta,
    );
    _cachedPdfBytes = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = size.width * 0.9;
    final dialogHeight = size.height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PreviewHeader(
                title: widget.title,
                meta: widget.meta,
                onClose: () => Navigator.of(context).pop(),
              ),
              _PreviewToolbar(
                activeTab: _tab,
                onTabChanged: (tab) => setState(() => _tab = tab),
                onDownloadPdf: () => _downloadPdf(context),
                onDownloadExcel: () => _downloadExcel(context),
                onPrint: () => _print(context),
                onOpenExternally: _canOpenExternally
                    ? () => _openPdf(context)
                    : null,
              ),
              const Divider(height: 1, color: reportCardBorder),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.rows.isEmpty) {
      return const Center(
        child: Text(
          'No data to preview',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return switch (_tab) {
      _ReportPreviewTab.table => _ReportPreviewTable(
        headers: widget.headers,
        rows: widget.rows,
      ),
      _ReportPreviewTab.pdf => _ReportPdfPreviewPane(
        title: widget.title,
        headers: widget.headers,
        rows: widget.rows,
        meta: widget.meta,
        filenameBase: widget.filenameBase,
      ),
    };
  }

  bool get _canOpenExternally => !kIsWeb && PlatformFileOutput.isDesktop;

  Future<void> _downloadPdf(BuildContext context) async {
    final bytes = await _buildPdfBytes();
    if (!context.mounted) return;
    await PlatformFileOutput.saveViaDialog(
      filename: '${widget.filenameBase}.pdf',
      bytes: bytes,
    );
  }

  void _downloadExcel(BuildContext context) {
    ExportActions.exportReportXlsx(
      context,
      sheetName: widget.title,
      filenameBase: widget.filenameBase,
      headers: widget.headers,
      rows: widget.rows,
    );
  }

  Future<void> _print(BuildContext context) async {
    final bytes = await _buildPdfBytes();
    if (!context.mounted) return;
    await _printOutput.printToDevice(
      context: context,
      document: PrintablePdf(
        bytes: bytes,
        name: widget.filenameBase,
        profile: PdfPageProfile.transactionCompact,
      ),
      format: PdfPageProfile.transactionCompact.printFormat,
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    try {
      final bytes = await _buildPdfBytes();
      if (!context.mounted) return;

      await PlatformFileOutput.openInDefaultViewer(
        bytes: bytes,
        filename: '${widget.filenameBase}.pdf',
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF: $error')),
      );
    }
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.title,
    required this.onClose,
    this.meta,
  });

  final String title;
  final ReportPreviewMeta? meta;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (meta?.hasValues ?? false) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (meta!.party case final party? when party.isNotEmpty)
                        _MetaChip(label: 'Party', value: party),
                      if (meta!.invoiceDate case final date?
                          when date.isNotEmpty)
                        _MetaChip(label: 'Invoice Date', value: date),
                      if (meta!.invoiceNumber case final number?
                          when number.isNotEmpty)
                        _MetaChip(label: 'Invoice Number', value: number),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.activeTab,
    required this.onTabChanged,
    required this.onDownloadPdf,
    required this.onDownloadExcel,
    required this.onPrint,
    this.onOpenExternally,
  });

  final _ReportPreviewTab activeTab;
  final ValueChanged<_ReportPreviewTab> onTabChanged;
  final VoidCallback onDownloadPdf;
  final VoidCallback onDownloadExcel;
  final VoidCallback onPrint;
  final VoidCallback? onOpenExternally;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<_ReportPreviewTab>(
            segments: const [
              ButtonSegment(
                value: _ReportPreviewTab.table,
                label: Text('Table'),
                icon: Icon(Icons.table_chart_outlined, size: 18),
              ),
              ButtonSegment(
                value: _ReportPreviewTab.pdf,
                label: Text('PDF'),
                icon: Icon(Icons.picture_as_pdf_outlined, size: 18),
              ),
            ],
            selected: {activeTab},
            onSelectionChanged: (selection) => onTabChanged(selection.first),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onDownloadPdf,
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download PDF'),
          ),
          OutlinedButton.icon(
            onPressed: onDownloadExcel,
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const Text('Download Excel'),
          ),
          OutlinedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Print'),
          ),
          if (onOpenExternally != null)
            OutlinedButton.icon(
              onPressed: onOpenExternally,
              icon: const Icon(Icons.open_in_new_outlined, size: 18),
              label: const Text('Open in new tab'),
            ),
        ],
      ),
    );
  }
}

class _ReportPreviewTable extends StatelessWidget {
  const _ReportPreviewTable({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: reportCardBorder),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StickyTableHeader(headers: headers),
                      ...List.generate(rows.length, (index) {
                        return _PreviewDataRow(
                          cells: rows[index],
                          headers: headers,
                          index: index,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StickyTableHeader extends StatelessWidget {
  const _StickyTableHeader({required this.headers});

  final List<String> headers;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: reportTableHeaderBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < headers.length; i++)
              Expanded(
                flex: i == headers.length - 2 && headers.length > 3 ? 2 : 1,
                child: Text(
                  headers[i].toUpperCase(),
                  textAlign: _columnAlign(headers[i]),
                  style: reportTableHeaderStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewDataRow extends StatelessWidget {
  const _PreviewDataRow({
    required this.cells,
    required this.headers,
    required this.index,
  });

  final List<String> cells;
  final List<String> headers;
  final int index;

  @override
  Widget build(BuildContext context) {
    final background = index.isEven ? AppColors.surface : reportSummaryTint;

    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < headers.length; i++)
              Expanded(
                flex: i == headers.length - 2 && headers.length > 3 ? 2 : 1,
                child: Text(
                  i < cells.length ? cells[i] : '',
                  textAlign: _columnAlign(headers[i]),
                  style: _cellStyle(headers[i], cells, i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _cellStyle(
    String header,
    List<String> cells,
    int index,
  ) {
    final value = index < cells.length ? cells[index] : '';
    final normalized = header.toLowerCase();
    if (normalized.contains('profit') || normalized.contains('loss')) {
      final numeric = value.replaceAll(RegExp(r'[^\d.\-]'), '');
      final amount = double.tryParse(numeric);
      if (amount != null) {
        return reportTableDataStyle.copyWith(
          color: amount >= 0 ? reportTeal : reportAddRed,
          fontWeight: FontWeight.w600,
        );
      }
    }
    return reportTableDataStyle;
  }
}

TextAlign _columnAlign(String header) {
  final normalized = header.toLowerCase();
  if (normalized.contains('amount') ||
      normalized.contains('profit') ||
      normalized.contains('loss') ||
      normalized.contains('balance') ||
      normalized.contains('debit') ||
      normalized.contains('credit') ||
      normalized.contains('qty') ||
      normalized.contains('quantity')) {
    return TextAlign.right;
  }
  return TextAlign.left;
}

class _ReportPdfPreviewPane extends StatelessWidget {
  const _ReportPdfPreviewPane({
    required this.title,
    required this.headers,
    required this.rows,
    required this.filenameBase,
    this.meta,
  });

  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final String filenameBase;
  final ReportPreviewMeta? meta;

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (_) => ReportPdfBuilder.build(
        title: title,
        headers: headers,
        rows: rows,
        meta: meta,
      ),
      pdfFileName: '$filenameBase.pdf',
      initialPageFormat: PdfPageProfile.transactionCompact.pageFormat,
      maxPageWidth: PdfPageProfile.transactionCompact.previewMaxPageWidth,
      allowPrinting: false,
      allowSharing: false,
      useActions: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      dynamicLayout: PdfPageProfile.transactionCompact.previewDynamicLayout,
      loadingWidget: const Center(child: CircularProgressIndicator()),
      onError: (context, error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Could not render PDF preview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
