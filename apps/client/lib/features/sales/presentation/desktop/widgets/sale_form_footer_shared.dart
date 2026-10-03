import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/attachments/document_attachment_service.dart';
import 'package:flutter/material.dart';

const saleFormFooterCardBorder = Color(0xFFE0E0E0);
const saleFormFooterCompactBreakpoint = 900.0;
const saleFormFooterAttachmentActionsWidthFactor = 0.5;
const saleFormFooterTermsSectionPadding = 12.0;
const saleFormFooterTermsNotesMinLines = 3;
const saleFormFooterTermsAndAttachmentPanelHeight =
    saleFormFooterTermsSectionPadding * 2 +
    18.0 +
    8.0 +
    saleFieldHeight +
    8.0 +
    20.0 +
    13.0 * 1.2 * saleFormFooterTermsNotesMinLines;

/// Three-column footer layout used by Add Sale and matching transaction forms.
class SaleFormFooterThreeColumnLayout extends StatelessWidget {
  const SaleFormFooterThreeColumnLayout({
    required this.termsSection,
    required this.attachmentActionsBox,
    required this.attachmentActionsBoxTall,
    required this.attachmentExtras,
    required this.totalsSection,
    super.key,
  });

  final Widget termsSection;
  final Widget attachmentActionsBox;
  final Widget attachmentActionsBoxTall;
  final Widget attachmentExtras;
  final Widget totalsSection;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < saleFormFooterCompactBreakpoint;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              termsSection,
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: saleFormFooterAttachmentActionsWidthFactor,
                  child: attachmentActionsBox,
                ),
              ),
              attachmentExtras,
              const SizedBox(height: 16),
              totalsSection,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: termsSection),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FractionallySizedBox(
                      widthFactor: saleFormFooterAttachmentActionsWidthFactor,
                      child: SizedBox(
                        height: saleFormFooterTermsAndAttachmentPanelHeight,
                        child: attachmentActionsBoxTall,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(width: 260, child: totalsSection),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 2, child: SizedBox.shrink()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: attachmentExtras),
                const SizedBox(width: 16),
                const SizedBox(width: 260),
              ],
            ),
          ],
        );
      },
    );
  }
}

class SaleFormFooterTermsSection extends StatelessWidget {
  const SaleFormFooterTermsSection({
    required this.title,
    required this.notes,
    required this.onTitleChanged,
    required this.onNotesChanged,
    super.key,
  });

  final String title;
  final String notes;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: saleFormFooterTermsAndAttachmentPanelHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: saleFormFooterCardBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(saleFormFooterTermsSectionPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SaleGenericSelectDropdown(
                value: title,
                options: SaleDropdownOptions.termsTitles,
                hintText: 'Title',
                onSelected: onTitleChanged,
              ),
              const SizedBox(height: 8),
              SaleFormFooterNotesField(
                initialValue: notes,
                onChanged: onNotesChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SaleFormFooterNotesField extends StatefulWidget {
  const SaleFormFooterNotesField({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<SaleFormFooterNotesField> createState() =>
      _SaleFormFooterNotesFieldState();
}

class _SaleFormFooterNotesFieldState extends State<SaleFormFooterNotesField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SaleFormFooterNotesField oldWidget) {
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
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      decoration: buildSaleFieldDecoration(
        hint: 'Thanks for doing business with us!',
        fixedHeight: false,
      ),
      minLines: saleFormFooterTermsNotesMinLines,
      maxLines: 4,
      onChanged: widget.onChanged,
    );
  }
}

class SaleFormFooterAttachmentActionsBox extends StatelessWidget {
  const SaleFormFooterAttachmentActionsBox({
    required this.expandVertically,
    required this.onAddDescription,
    required this.onAddImage,
    required this.onAddDocument,
    super.key,
  });

  final bool expandVertically;
  final VoidCallback onAddDescription;
  final VoidCallback onAddImage;
  final VoidCallback onAddDocument;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _SaleFormFooterAttachmentActionButton(
        icon: Icons.description_outlined,
        label: 'ADD DESCRIPTION',
        onPressed: onAddDescription,
        expand: expandVertically,
      ),
      _SaleFormFooterAttachmentActionButton(
        icon: Icons.camera_alt_outlined,
        label: 'ADD IMAGE',
        onPressed: onAddImage,
        expand: expandVertically,
      ),
      _SaleFormFooterAttachmentActionButton(
        icon: Icons.attach_file_outlined,
        label: 'ADD DOCUMENT',
        filled: true,
        onPressed: onAddDocument,
        expand: expandVertically,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: saleFormFooterCardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: expandVertically
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: buttons[0]),
                  const SizedBox(height: 8),
                  Expanded(child: buttons[1]),
                  const SizedBox(height: 8),
                  Expanded(child: buttons[2]),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buttons[0],
                  const SizedBox(height: 8),
                  buttons[1],
                  const SizedBox(height: 8),
                  buttons[2],
                ],
              ),
      ),
    );
  }
}

class SaleFormFooterAttachmentExtras extends StatelessWidget {
  const SaleFormFooterAttachmentExtras({
    required this.showDescription,
    required this.description,
    required this.attachedImages,
    required this.attachedDocuments,
    required this.attachmentService,
    required this.onDescriptionChanged,
    required this.onRemoveImage,
    required this.onRenameImage,
    required this.onRemoveDocument,
    required this.onRenameDocument,
    super.key,
  });

  final bool showDescription;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final DocumentAttachmentService? attachmentService;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onRemoveImage;
  final void Function(String id, String name) onRenameImage;
  final ValueChanged<String> onRemoveDocument;
  final void Function(String id, String name) onRenameDocument;

  @override
  Widget build(BuildContext context) {
    final hasExtras =
        showDescription ||
        attachedImages.isNotEmpty ||
        attachedDocuments.isNotEmpty;
    if (!hasExtras) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDescription) ...[
          const SizedBox(height: 8),
          SaleFormFooterDescriptionField(
            initialValue: description,
            onChanged: onDescriptionChanged,
          ),
        ],
        if (attachedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          SaleFormAttachmentChipList(
            attachments: attachedImages,
            attachmentService: attachmentService,
            onRemove: onRemoveImage,
            onRename: onRenameImage,
          ),
        ],
        if (attachedDocuments.isNotEmpty) ...[
          const SizedBox(height: 8),
          SaleFormAttachmentChipList(
            attachments: attachedDocuments,
            attachmentService: attachmentService,
            onRemove: onRemoveDocument,
            onRename: onRenameDocument,
          ),
        ],
      ],
    );
  }
}

class SaleFormFooterDescriptionField extends StatefulWidget {
  const SaleFormFooterDescriptionField({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<SaleFormFooterDescriptionField> createState() =>
      _SaleFormFooterDescriptionFieldState();
}

class _SaleFormFooterDescriptionFieldState
    extends State<SaleFormFooterDescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SaleFormFooterDescriptionField oldWidget) {
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
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      decoration: buildSaleFieldDecoration(
        hint: 'Write your description here',
        fixedHeight: false,
      ),
      minLines: 3,
      maxLines: 4,
      onChanged: widget.onChanged,
    );
  }
}

class _SaleFormFooterAttachmentActionButton extends StatelessWidget {
  const _SaleFormFooterAttachmentActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: expand ? double.infinity : null,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: filled ? const Color(0xFFF5F8FA) : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          minimumSize: expand ? Size.zero : null,
          tapTargetSize: expand ? MaterialTapTargetSize.shrinkWrap : null,
          side: const BorderSide(color: saleFormFooterCardBorder),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
