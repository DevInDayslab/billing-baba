import 'dart:typed_data';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/connectivity_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_provider.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:billing_baba/shared/widgets/offline_status_banner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justkawal_excel_updated/justkawal_excel_updated.dart'
    hide Border;

class ImportItemsExcelContent extends StatefulWidget {
  const ImportItemsExcelContent({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<ImportItemsExcelContent> createState() =>
      _ImportItemsExcelContentState();
}

class _ImportItemsExcelContentState extends State<ImportItemsExcelContent> {
  static const _headingBlue = Color(0xFF1A237E);
  static const _cardBorder = Color(0xFFE0E0E0);

  final _scrollController = ScrollController();
  final GlobalKey<State<StatefulWidget>> _previewSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPreview() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final previewContext = _previewSectionKey.currentContext;
      if (previewContext != null && mounted) {
        Scrollable.ensureVisible(
          previewContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(importItemsExcelProvider);

        ref.listen(importItemsExcelProvider, (previous, next) {
          if (next.parseError != null &&
              next.parseError != previous?.parseError &&
              !next.isParsing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.parseError!)),
            );
          }

          if (previous?.isParsing == true &&
              !next.isParsing &&
              next.parseError == null &&
              next.rows.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Parsed ${next.rows.length} item${next.rows.length == 1 ? '' : 's'} '
                  '(${next.validCount} ready to import)',
                ),
                backgroundColor: inventoryPositiveColor,
              ),
            );
            _scrollToPreview();
          }
        });

        return Stack(
          children: [
            _buildContent(context, ref, state),
            if (state.isParsing) _ParsingOverlay(fileName: state.fileName),
            if (state.isImporting) const _ImportingOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ImportItemsExcelState state,
  ) {
    final isOnline = ref.watch(networkConnectivityProvider);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isOnline)
            const OfflineStatusBanner(
              message: 'Offline — connect to the internet to import items',
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.lgBorder,
                    border: Border.all(color: _cardBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final useColumn = constraints.maxWidth < 720;
                        final stepsPanel = _StepsPanel(
                          onDownloadSample: _downloadSample,
                        );
                        final uploadPanel = _UploadPanel(
                          fileName: state.isParsing ? null : state.fileName,
                          onBrowse: state.isParsing
                              ? null
                              : () => _pickFile(ref),
                          minHeight: useColumn ? 280 : null,
                        );

                        if (useColumn) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              stepsPanel,
                              const SizedBox(height: AppSpacing.xl),
                              uploadPanel,
                            ],
                          );
                        }

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: stepsPanel),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(child: uploadPanel),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (state.rows.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  KeyedSubtree(
                    key: _previewSectionKey,
                    child: _PreviewSection(
                      state: state,
                      onToggleRow: (id, selected) => ref
                          .read(importItemsExcelProvider.notifier)
                          .toggleRowSelection(id, selected: selected),
                      onSelectAllValid: (selected) => ref
                          .read(importItemsExcelProvider.notifier)
                          .selectAllValid(selected: selected),
                      onImport: () => _confirmImport(context, ref),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (widget.onBack != null)
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: _headingBlue),
            tooltip: 'Back',
          ),
        const Expanded(
          child: Text(
            'Import Items From Excel File',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _headingBlue,
            ),
          ),
        ),
        if (widget.onBack != null) const SizedBox(width: 48),
      ],
    );
  }

  Future<void> _downloadSample() async {
    final excel = Excel.createExcel();
    const sheetName = 'Items';
    final sheet = excel[sheetName];
    excel.delete('Sheet1');

    for (var i = 0; i < ImportItemsExcelParser.templateHeaders.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(
        ImportItemsExcelParser.templateHeaders[i],
      );
    }

    for (
      var rowIndex = 0;
      rowIndex < ImportItemsExcelParser.sampleRows.length;
      rowIndex++
    ) {
      final sampleRow = ImportItemsExcelParser.sampleRows[rowIndex];
      for (var colIndex = 0; colIndex < sampleRow.length; colIndex++) {
        final cellValue = sampleRow[colIndex];
        final excelRow = rowIndex + 1;
        final parsed = double.tryParse(cellValue);
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: colIndex,
                rowIndex: excelRow,
              ),
            )
            .value = parsed != null && colIndex >= 2
            ? DoubleCellValue(parsed)
            : TextCellValue(cellValue);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final path = await PlatformFileOutput.saveViaDialog(
      filename: 'billing_baba_items_sample.xlsx',
      bytes: Uint8List.fromList(bytes),
    );

    if (!mounted || path == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample template saved successfully')),
    );
  }

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.first;
    ref.read(importItemsExcelProvider.notifier).beginParsing(file.name);

    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await ref.read(importItemsExcelProvider.notifier).parseBytes(bytes);
    } on Object catch (error) {
      if (!mounted) return;
      ref
          .read(importItemsExcelProvider.notifier)
          .cancelParsing(
            error: 'Failed to read file: $error',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read file: $error')),
      );
    }
  }

  Future<void> _confirmImport(BuildContext context, WidgetRef ref) async {
    final excelState = ref.read(importItemsExcelProvider);
    if (!excelState.canImport) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one valid item to import.'),
        ),
      );
      return;
    }

    try {
      final result = await ref
          .read(importItemsExcelProvider.notifier)
          .confirmImport();
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No items were selected for import.'),
          ),
        );
        return;
      }

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            result.failedCount == 0 ? 'Import Successful' : 'Import Completed',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.successCount} item${result.successCount == 1 ? '' : 's'} imported successfully.',
              ),
              if (result.failedCount > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${result.failedCount} item${result.failedCount == 1 ? '' : 's'} failed to import.',
                  style: const TextStyle(color: inventoryNegativeColor),
                ),
              ],
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Errors:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...result.errors
                    .take(5)
                    .map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          error,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (result.successCount > 0) {
        ref.read(importItemsExcelProvider.notifier).reset();
        widget.onBack?.call();
      }
    } on ApiValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on InventoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    }
  }
}

class _StepsPanel extends StatelessWidget {
  const _StepsPanel({required this.onDownloadSample});

  final VoidCallback onDownloadSample;

  static const _headingBlue = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Steps to Import',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _headingBlue,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _StepBlock(
          stepLabel: 'STEP 1',
          description:
              'Download the sample template and fill in your item details.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DownloadTemplateButton(onPressed: onDownloadSample),
              const SizedBox(height: AppSpacing.md),
              const _TemplateInfoBox(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _StepBlock(
          stepLabel: 'STEP 2',
          description:
              'Upload the filled .xlsx or .xls file using the panel on the right.',
        ),
        const SizedBox(height: AppSpacing.lg),
        const _StepBlock(
          stepLabel: 'STEP 3',
          description:
              'Review items — duplicates and errors are highlighted '
              'automatically. Confirm to import valid items.',
        ),
      ],
    );
  }
}

class _DownloadTemplateButton extends StatelessWidget {
  const _DownloadTemplateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      ),
      icon: const Icon(Icons.download_outlined, size: 18),
      label: const Text(
        'Download Sample Template',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TemplateInfoBox extends StatelessWidget {
  const _TemplateInfoBox();

  static const _infoBackground = Color(0xFFF5F5F5);
  static const _stepRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _infoBackground,
        borderRadius: AppRadius.mdBorder,
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template columns:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Item Name*, Type (product/service), Sale Price, Purchase Price, '
              'Tax Rate (%), Unit, HSN/SAC Code, Opening Quantity',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '* Item Name is required and must be unique',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _stepRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBlock extends StatelessWidget {
  const _StepBlock({
    required this.stepLabel,
    required this.description,
    this.child,
  });

  final String stepLabel;
  final String description;
  final Widget? child;

  static const _stepRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stepLabel,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _stepRed,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.45,
          ),
        ),
        if (child != null) ...[
          const SizedBox(height: AppSpacing.md),
          child!,
        ],
      ],
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.onBrowse,
    this.fileName,
    this.minHeight,
  });

  final String? fileName;
  final VoidCallback? onBrowse;
  final double? minHeight;

  static const _uploadBackground = Color(0xFFF8F9FB);
  static const _uploadBorder = Color(0xFF90CAF9);
  static const _stepRed = Color(0xFFE53935);
  static const _headingBlue = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _uploadBackground,
        borderRadius: AppRadius.lgBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload your .xls / .xlsx file',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _headingBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              fit: minHeight != null ? FlexFit.loose : FlexFit.tight,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight ?? 220),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(color: _uploadBorder, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 52,
                          color: AppColors.primary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Drag & Drop file here',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          'or',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: onBrowse,
                          style: FilledButton.styleFrom(
                            backgroundColor: _stepRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text(
                            'Browse File',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (fileName != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            fileName!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
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

class _ParsingOverlay extends StatelessWidget {
  const _ParsingOverlay({this.fileName});

  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: const Color(0x66000000),
          child: Center(
            child: Material(
              elevation: 8,
              borderRadius: AppRadius.lgBorder,
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Parsing Excel File',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      fileName ?? 'Reading file...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImportingOverlay extends ConsumerWidget {
  const _ImportingOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importItemsExcelProvider);

    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: const Color(0x66000000),
          child: Center(
            child: Material(
              elevation: 8,
              borderRadius: AppRadius.lgBorder,
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Importing Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: state.importTotal == 0
                            ? null
                            : state.importCompleted / state.importTotal,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Imported ${state.importCompleted} of ${state.importTotal}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.state,
    required this.onToggleRow,
    required this.onSelectAllValid,
    required this.onImport,
  });

  final ImportItemsExcelState state;
  final void Function(String id, bool selected) onToggleRow;
  final void Function(bool selected) onSelectAllValid;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final allValidSelected = state.rows
        .where((row) => row.status == ImportRowStatus.valid)
        .every((row) => row.isSelected);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.showParseSuccess) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: inventoryPositiveColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: inventoryPositiveColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: inventoryPositiveColor,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          state.fileName == null
                              ? 'File parsed successfully. '
                                    '${state.rows.length} item${state.rows.length == 1 ? '' : 's'} found.'
                              : '"${state.fileName}" parsed successfully. '
                                    '${state.rows.length} item${state.rows.length == 1 ? '' : 's'} found.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Review Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _SummaryChip(
                      label: '${state.validCount} Valid',
                      color: inventoryPositiveColor,
                    ),
                    _SummaryChip(
                      label: '${state.duplicateCount} Duplicate',
                      color: inventoryNegativeColor,
                    ),
                    _SummaryChip(
                      label: '${state.errorCount} Error',
                      color: const Color(0xFFE65100),
                    ),
                  ],
                ),
              ],
            ),
            if (state.errorCount > 0) ...[
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    '${state.errorCount} row${state.errorCount == 1 ? '' : 's'} '
                    'could not be imported. See the Issue column for details. '
                    'This often happens when no units are set up in Inventory.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _PreviewTable(
              rows: state.rows,
              onToggleRow: onToggleRow,
              allValidSelected: allValidSelected,
              onSelectAllValid: onSelectAllValid,
            ),
            if (state.isImporting) ...[
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: state.importTotal == 0
                    ? null
                    : state.importCompleted / state.importTotal,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Importing ${state.importCompleted} of ${state.importTotal}...',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (state.importError != null) ...[
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: inventoryNegativeColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: inventoryNegativeColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    state.importError!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: state.canImport ? onImport : null,
                style: FilledButton.styleFrom(
                  backgroundColor: inventoryPrimaryOrange,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  state.isImporting
                      ? 'Importing...'
                      : 'Confirm Import (${state.selectedCount})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({
    required this.rows,
    required this.onToggleRow,
    required this.allValidSelected,
    required this.onSelectAllValid,
  });

  final List<ImportItemPreviewRow> rows;
  final void Function(String id, bool selected) onToggleRow;
  final bool allValidSelected;
  final void Function(bool selected) onSelectAllValid;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.mdBorder,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: AppRadius.mdBorder,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
            columns: [
              DataColumn(
                label: Checkbox(
                  value: allValidSelected,
                  onChanged:
                      rows.any(
                        (row) => row.status == ImportRowStatus.valid,
                      )
                      ? (value) => onSelectAllValid(value ?? false)
                      : null,
                ),
              ),
              const DataColumn(label: Text('Row')),
              const DataColumn(label: Text('Item Name')),
              const DataColumn(label: Text('Type')),
              const DataColumn(label: Text('Sale Price')),
              const DataColumn(label: Text('Purchase Price')),
              const DataColumn(label: Text('Tax Rate')),
              const DataColumn(label: Text('Unit')),
              const DataColumn(label: Text('HSN/SAC')),
              const DataColumn(label: Text('Opening Qty')),
              const DataColumn(label: Text('Status')),
              const DataColumn(label: Text('Issue')),
            ],
            rows: [
              for (final row in rows)
                DataRow(
                  color: WidgetStateProperty.all(
                    row.status == ImportRowStatus.duplicate
                        ? const Color(0xFFFFEBEE)
                        : row.status == ImportRowStatus.error
                        ? const Color(0xFFFFF3E0)
                        : null,
                  ),
                  cells: [
                    DataCell(
                      Checkbox(
                        value: row.isSelected,
                        onChanged: row.status == ImportRowStatus.valid
                            ? (value) => onToggleRow(row.id, value ?? false)
                            : null,
                      ),
                    ),
                    DataCell(Text('${row.sheetRowNumber}')),
                    DataCell(Text(row.itemName)),
                    DataCell(Text(row.typeLabel)),
                    DataCell(Text(row.salePrice)),
                    DataCell(Text(row.purchasePrice)),
                    DataCell(Text(row.taxRate)),
                    DataCell(Text(row.unit)),
                    DataCell(Text(row.hsnSac)),
                    DataCell(Text(row.openingQty)),
                    DataCell(
                      Text(
                        switch (row.status) {
                          ImportRowStatus.valid => 'Valid',
                          ImportRowStatus.duplicate => 'Duplicate',
                          ImportRowStatus.error => 'Error',
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: switch (row.status) {
                            ImportRowStatus.valid => inventoryPositiveColor,
                            ImportRowStatus.duplicate => inventoryNegativeColor,
                            ImportRowStatus.error => const Color(0xFFE65100),
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        row.issueMessage ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
