import 'dart:typed_data';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Opens an in-app PDF preview with Print, Download, and Share actions.
Future<void> showDocumentPdfPreviewDialog({
  required BuildContext context,
  required PrintablePdf document,
  int copies = 1,
  PrintOutputService? outputService,
}) {
  final service = outputService ?? PrintOutputService();

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => DocumentPdfPreviewDialog(
      document: document,
      copies: copies,
      outputService: service,
    ),
  );
}

class DocumentPdfPreviewDialog extends StatefulWidget {
  const DocumentPdfPreviewDialog({
    required this.document,
    required this.outputService,
    this.copies = 1,
    super.key,
  });

  final PrintablePdf document;
  final PrintOutputService outputService;
  final int copies;

  @override
  State<DocumentPdfPreviewDialog> createState() =>
      _DocumentPdfPreviewDialogState();
}

class _DocumentPdfPreviewDialogState extends State<DocumentPdfPreviewDialog> {
  bool _isPrinting = false;
  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _runAction({
    required Future<void> Function() action,
    required VoidCallback setLoading,
    required VoidCallback clearLoading,
  }) async {
    if (_isPrinting || _isSaving || _isSharing) return;
    setLoading();
    try {
      await action();
    } finally {
      if (mounted) clearLoading();
    }
  }

  Future<void> _print() async {
    await _runAction(
      setLoading: () => setState(() => _isPrinting = true),
      clearLoading: () => setState(() => _isPrinting = false),
      action: () => widget.outputService.printToDevice(
        context: context,
        document: widget.document,
        format: widget.document.profile.printFormat,
        copies: widget.copies,
      ),
    );
  }

  Future<void> _download() async {
    await _runAction(
      setLoading: () => setState(() => _isSaving = true),
      clearLoading: () => setState(() => _isSaving = false),
      action: () async {
        final path = await widget.outputService.save(
          bytes: widget.document.bytes,
          filename: widget.document.filename,
        );
        if (!mounted) return;
        final message = path != null
            ? 'PDF saved to $path'
            : 'PDF ready to share';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  Future<void> _share() async {
    await _runAction(
      setLoading: () => setState(() => _isSharing = true),
      clearLoading: () => setState(() => _isSharing = false),
      action: () => widget.outputService.share(
        bytes: widget.document.bytes,
        filename: widget.document.filename,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final title = _displayTitle(widget.document.name);

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
          width: size.width * 0.9,
          height: size.height * 0.88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DocumentPreviewHeader(
                title: title,
                onClose: () => Navigator.of(context).pop(),
              ),
              _DocumentPreviewToolbar(
                isPrinting: _isPrinting,
                isSaving: _isSaving,
                isSharing: _isSharing,
                onPrint: _print,
                onDownload: _download,
                onShare: _share,
              ),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              Expanded(
                child: _DocumentPdfPreviewPane(
                  bytes: widget.document.bytes,
                  filename: widget.document.filename,
                  profile: widget.document.profile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _displayTitle(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Document preview';
  return trimmed.endsWith('.pdf')
      ? trimmed.substring(0, trimmed.length - 4)
      : trimmed;
}

class _DocumentPreviewHeader extends StatelessWidget {
  const _DocumentPreviewHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
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
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
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

class _DocumentPreviewToolbar extends StatelessWidget {
  const _DocumentPreviewToolbar({
    required this.isPrinting,
    required this.isSaving,
    required this.isSharing,
    required this.onPrint,
    required this.onDownload,
    required this.onShare,
  });

  final bool isPrinting;
  final bool isSaving;
  final bool isSharing;
  final VoidCallback onPrint;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isBusy = isPrinting || isSaving || isSharing;

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
          FilledButton.icon(
            onPressed: isBusy ? null : onPrint,
            icon: isPrinting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print_outlined, size: 18),
            label: const Text('Print'),
          ),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onDownload,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download PDF'),
          ),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onShare,
            icon: isSharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _DocumentPdfPreviewPane extends StatelessWidget {
  const _DocumentPdfPreviewPane({
    required this.bytes,
    required this.filename,
    required this.profile,
  });

  final Uint8List bytes;
  final String filename;
  final PdfPageProfile profile;

  @override
  Widget build(BuildContext context) {
    final maxWidth = profile.previewMaxPageWidth.isFinite
        ? profile.previewMaxPageWidth
        : null;

    return PdfPreview(
      build: (_) async => bytes,
      pdfFileName: filename,
      initialPageFormat: profile.pageFormat,
      maxPageWidth: maxWidth,
      allowPrinting: false,
      allowSharing: false,
      useActions: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      dynamicLayout: profile.previewDynamicLayout,
      scrollViewDecoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
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
                OfflineUiMessages.messageFor(error),
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
