import 'package:billing_baba/core/attachments/attachment_picker.dart';
import 'package:billing_baba/core/attachments/document_attachment_service.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/text_input_dialog.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Description, image, and document fields shared across transaction forms.
class SaleFormAttachmentsSection extends StatelessWidget {
  const SaleFormAttachmentsSection({
    required this.description,
    required this.images,
    required this.documents,
    required this.onDescriptionChanged,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onUpdateImage,
    required this.onAddDocument,
    required this.onRemoveDocument,
    required this.onUpdateDocument,
    this.entityType,
    this.entityId,
    this.attachmentService,
    super.key,
  });

  final String description;
  final List<SaleFormAttachment> images;
  final List<SaleFormAttachment> documents;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onAddImage;
  final ValueChanged<String> onRemoveImage;
  final void Function(String id, String name) onUpdateImage;
  final VoidCallback onAddDocument;
  final ValueChanged<String> onRemoveDocument;
  final void Function(String id, String name) onUpdateDocument;
  final String? entityType;
  final String? entityId;
  final DocumentAttachmentService? attachmentService;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Description', style: saleFieldLabelStyle),
              const SizedBox(height: 4),
              _DescriptionField(
                initialValue: description,
                onChanged: onDescriptionChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Image', style: saleFieldLabelStyle),
              const SizedBox(height: 4),
              _UploadZone(
                icon: Icons.camera_alt_outlined,
                label: 'Upload Image',
                onTap: onAddImage,
              ),
              if (images.isNotEmpty) ...[
                const SizedBox(height: 6),
                _AttachmentList(
                  attachments: images,
                  attachmentService: attachmentService,
                  onRemove: onRemoveImage,
                  onRename: onUpdateImage,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Document', style: saleFieldLabelStyle),
              const SizedBox(height: 4),
              _UploadZone(
                icon: Icons.description_outlined,
                label: 'Upload PDF / Image',
                filled: true,
                onTap: onAddDocument,
              ),
              if (documents.isNotEmpty) ...[
                const SizedBox(height: 6),
                _AttachmentList(
                  attachments: documents,
                  attachmentService: attachmentService,
                  onRemove: onRemoveDocument,
                  onRename: onUpdateDocument,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SaleFormAttachmentChipList extends StatelessWidget {
  const SaleFormAttachmentChipList({
    required this.attachments,
    required this.onRemove,
    required this.onRename,
    this.attachmentService,
    super.key,
  });

  final List<SaleFormAttachment> attachments;
  final ValueChanged<String> onRemove;
  final void Function(String id, String name) onRename;
  final DocumentAttachmentService? attachmentService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final attachment in attachments)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _AttachmentChip(
              attachment: attachment,
              attachmentService: attachmentService,
              onRemove: () => onRemove(attachment.id),
              onRename: () => _promptRename(context, attachment),
            ),
          ),
      ],
    );
  }

  Future<void> _promptRename(
    BuildContext context,
    SaleFormAttachment attachment,
  ) async {
    final newName = await showTextInputDialog(
      context,
      title: 'Rename attachment',
      hint: 'File name',
      initialValue: attachment.displayName,
    );
    if (newName != null && newName.isNotEmpty) {
      onRename(attachment.id, newName);
    }
  }
}

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({
    required this.attachments,
    required this.onRemove,
    required this.onRename,
    this.attachmentService,
  });

  final List<SaleFormAttachment> attachments;
  final ValueChanged<String> onRemove;
  final void Function(String id, String name) onRename;
  final DocumentAttachmentService? attachmentService;

  @override
  Widget build(BuildContext context) {
    return SaleFormAttachmentChipList(
      attachments: attachments,
      onRemove: onRemove,
      onRename: onRename,
      attachmentService: attachmentService,
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
    required this.onRename,
    this.attachmentService,
  });

  final SaleFormAttachment attachment;
  final VoidCallback onRemove;
  final VoidCallback onRename;
  final DocumentAttachmentService? attachmentService;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            if (attachment.canPreview) ...[
              _AttachmentThumb(attachment: attachment),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: InkWell(
                onTap: onRename,
                child: Text(
                  attachment.displayName,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (attachmentService != null && attachment.remoteId != null)
              IconButton(
                tooltip: 'Download',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.download_outlined, size: 16),
                onPressed: () => _download(context),
              ),
            IconButton(
              tooltip: 'Preview',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              onPressed: attachment.canPreview
                  ? () => _preview(context)
                  : null,
            ),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    final service = attachmentService;
    if (service == null) return;
    try {
      final url = await service.resolveDownloadUrl(attachment);
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $error')),
        );
      }
    }
  }

  void _preview(BuildContext context) {
    if (attachment.localBytes != null) {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: Image.memory(attachment.localBytes!, fit: BoxFit.contain),
        ),
      );
      return;
    }

    final url = attachment.fileUrl;
    if (url == null || url.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: AppNetworkImage(imageUrl: url, fit: BoxFit.contain),
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({required this.attachment});

  final SaleFormAttachment attachment;

  @override
  Widget build(BuildContext context) {
    if (attachment.localBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          attachment.localBytes!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      );
    }

    final url = attachment.fileUrl;
    if (url == null || url.isEmpty) {
      return const Icon(Icons.insert_photo_outlined, size: 20);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AppNetworkImage(
        imageUrl: url,
        width: 32,
        height: 32,
        memCacheWidth: 64,
      ),
    );
  }
}

class _DescriptionField extends StatefulWidget {
  const _DescriptionField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_DescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: TextField(
        controller: _controller,
        style: saleFieldTextStyle,
        decoration: buildSaleFieldDecoration(
          hint: 'Write your description here',
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: CustomPaint(
        painter: const _DashedBorderPainter(color: Color(0xFFBDBDBD)),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: filled ? const Color(0xFFF5F8FA) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
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

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 6.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          const Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Legacy helper — opens file picker instead of name-only prompt.
Future<SaleFormAttachment?> promptSaleFormAttachment(
  BuildContext context, {
  required String title,
  required String defaultName,
  bool imagesOnly = false,
}) => pickTransactionAttachment(imagesOnly: imagesOnly);
