import 'dart:async';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/utilities/application/import_excel_template.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_provider.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mobile Excel import flow — reuses [importPartiesExcelProvider].
class MobileImportPartiesExcelContent extends ConsumerStatefulWidget {
  const MobileImportPartiesExcelContent({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<MobileImportPartiesExcelContent> createState() =>
      _MobileImportPartiesExcelContentState();
}

class _MobileImportPartiesExcelContentState
    extends ConsumerState<MobileImportPartiesExcelContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importPartiesExcelProvider);

    ref.listen(importPartiesExcelProvider, (previous, next) {
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
              'Parsed ${next.rows.length} part${next.rows.length == 1 ? 'y' : 'ies'} '
              '(${next.validCount} ready to import)',
            ),
            backgroundColor: inventoryPositiveColor,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        showBackButton: true,
        onBack: widget.onBack,
        title: 'Import Parties',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              children: [
                _StepsCard(
                  onDownloadSample: () => unawaited(_downloadSample()),
                ),
                const SizedBox(height: AppSpacing.lg),
                _UploadCard(
                  fileName: state.isParsing ? null : state.fileName,
                  onBrowse: state.isParsing
                      ? null
                      : () => unawaited(_pickFile()),
                ),
                if (state.rows.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _PreviewSection(
                    state: state,
                    onToggleRow: (id, selected) => ref
                        .read(importPartiesExcelProvider.notifier)
                        .toggleRowSelection(id, selected: selected),
                    onSelectAllValid: (selected) => ref
                        .read(importPartiesExcelProvider.notifier)
                        .selectAllValid(selected: selected),
                    onImport: () => unawaited(_confirmImport()),
                  ),
                ],
              ],
            ),
          ),
          if (state.isParsing) _ParsingOverlay(fileName: state.fileName),
          if (state.isImporting) const _ImportingOverlay(),
        ],
      ),
    );
  }

  Future<void> _downloadSample() async {
    final bytes = buildImportPartiesSampleTemplateBytes();
    if (bytes == null || !mounted) return;

    await PlatformFileOutput.shareFromTemp(
      filename: 'billing_baba_parties_sample.xlsx',
      bytes: bytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      extension: 'xlsx',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample template ready to share or save')),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (!mounted || result.isEmpty) return;

    final file = result.first;
    ref.read(importPartiesExcelProvider.notifier).beginParsing(file.name);

    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await ref.read(importPartiesExcelProvider.notifier).parseBytes(bytes);
    } on Object catch (error) {
      if (!mounted) return;
      ref
          .read(importPartiesExcelProvider.notifier)
          .cancelParsing(
            error: 'Failed to read file: $error',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read file: $error')),
      );
    }
  }

  Future<void> _confirmImport() async {
    final excelState = ref.read(importPartiesExcelProvider);
    if (!excelState.canImport) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one valid party to import.'),
        ),
      );
      return;
    }

    try {
      final result = await ref
          .read(importPartiesExcelProvider.notifier)
          .confirmImport();
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No parties were selected for import.')),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            result.failedCount == 0 ? 'Import Successful' : 'Import Completed',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.successCount} part${result.successCount == 1 ? 'y' : 'ies'} imported successfully.',
                ),
                if (result.failedCount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${result.failedCount} part${result.failedCount == 1 ? 'y' : 'ies'} failed.',
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
        ref.read(importPartiesExcelProvider.notifier).reset();
        widget.onBack?.call();
      }
    } on ApiValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on PartyException catch (error) {
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

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.onDownloadSample});

  final VoidCallback onDownloadSample;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Steps to Import',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _StepLine(
              step: 'STEP 1',
              text:
                  'Download the sample template and fill in your party details.',
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onDownloadSample,
              icon: const Icon(LucideIcons.download),
              label: const Text('Download Sample Template'),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _StepLine(
              step: 'STEP 2',
              text: 'Upload the filled .xlsx or .xls file.',
            ),
            const SizedBox(height: AppSpacing.lg),
            const _StepLine(
              step: 'STEP 3',
              text:
                  'Review parties — duplicates and errors are highlighted. Confirm to import.',
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Template columns: Party Name*, Mobile*, Type, Email, GSTIN, '
              'State, Party Group, Opening Balance',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.step, required this.text});

  final String step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE53935),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.onBrowse,
    this.fileName,
  });

  final VoidCallback? onBrowse;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8F9FB),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: const BorderSide(color: Color(0xFF90CAF9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(
              LucideIcons.upload,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              fileName ?? 'Upload Excel File',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Supported: .xlsx, .xls',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Browse Files'),
            ),
          ],
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

  final ImportPartiesExcelState state;
  final void Function(String id, bool selected) onToggleRow;
  final void Function(bool selected) onSelectAllValid;
  final VoidCallback onImport;

  Color _statusColor(ImportRowStatus status) => switch (status) {
    ImportRowStatus.valid => inventoryPositiveColor,
    ImportRowStatus.duplicate => inventoryNegativeColor,
    ImportRowStatus.error => const Color(0xFFE65100),
  };

  String _statusLabel(ImportRowStatus status) => switch (status) {
    ImportRowStatus.valid => 'Valid',
    ImportRowStatus.duplicate => 'Duplicate',
    ImportRowStatus.error => 'Error',
  };

  @override
  Widget build(BuildContext context) {
    final allValidSelected = state.rows
        .where((row) => row.status == ImportRowStatus.valid)
        .every((row) => row.isSelected);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Review Parties',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: allValidSelected && state.validCount > 0,
              onChanged: state.validCount == 0
                  ? null
                  : (value) => onSelectAllValid(value ?? false),
              title: const Text('Select all valid parties'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.rows.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final row = state.rows[index];
                final color = _statusColor(row.status);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: row.status == ImportRowStatus.valid
                      ? Checkbox(
                          value: row.isSelected,
                          onChanged: (value) =>
                              onToggleRow(row.id, value ?? false),
                        )
                      : Icon(LucideIcons.ban, color: color, size: 22),
                  title: Text(
                    row.partyName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${row.typeLabel} · ${row.mobile} · Bal ${row.openingBalance}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (row.issueMessage != null)
                        Text(
                          row.issueMessage!,
                          style: TextStyle(fontSize: 12, color: color),
                        ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusLabel(row.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: state.canImport ? onImport : null,
              style: FilledButton.styleFrom(
                backgroundColor: MobileHomeAddSaleFab.accentRed,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                state.isImporting
                    ? 'Importing...'
                    : 'Confirm Import (${state.selectedCount})',
                style: const TextStyle(fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      fileName == null
                          ? 'Parsing file...'
                          : 'Parsing $fileName',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
    final state = ref.watch(importPartiesExcelProvider);

    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: const Color(0x66000000),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Importing Parties',
                        style: TextStyle(fontWeight: FontWeight.w700),
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
