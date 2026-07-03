import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

/// Description, image, and document fields shared across sale document forms.
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
                label: 'Upload Document',
                filled: true,
                onTap: onAddDocument,
              ),
              if (documents.isNotEmpty) ...[
                const SizedBox(height: 6),
                _AttachmentList(
                  attachments: documents,
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

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({
    required this.attachments,
    required this.onRemove,
    required this.onRename,
  });

  final List<SaleFormAttachment> attachments;
  final ValueChanged<String> onRemove;
  final void Function(String id, String name) onRename;

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
    final controller = TextEditingController(text: attachment.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename attachment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'File name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      onRename(attachment.id, newName);
    }
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
    required this.onRename,
  });

  final SaleFormAttachment attachment;
  final VoidCallback onRemove;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onRename,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  attachment.displayName,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

/// Prompts the user to name an in-memory attachment.
Future<SaleFormAttachment?> promptSaleFormAttachment(
  BuildContext context, {
  required String title,
  required String defaultName,
}) async {
  final controller = TextEditingController(text: defaultName);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'File name',
          hintText: 'e.g. product_photo.png',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
  if (name == null || name.isEmpty) return null;
  return SaleFormAttachment.create(name: name);
}
