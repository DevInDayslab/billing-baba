import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_document_visibility.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Description, terms, and attachment actions matching desktop transaction forms.
class MobileDocumentNotesAttachmentsSection extends StatelessWidget {
  const MobileDocumentNotesAttachmentsSection({
    required this.visibility,
    super.key,
    this.descriptionController,
    this.onDescriptionChanged,
    this.termsTitle,
    this.termsTextController,
    this.onTermsTitleTap,
    this.onTermsTextChanged,
    this.images = const [],
    this.documents = const [],
    this.onAddImage,
    this.onAddDocument,
    this.onRemoveImage,
    this.onRemoveDocument,
  });

  final MobileDocumentVisibility visibility;
  final TextEditingController? descriptionController;
  final ValueChanged<String>? onDescriptionChanged;
  final String? termsTitle;
  final TextEditingController? termsTextController;
  final VoidCallback? onTermsTitleTap;
  final ValueChanged<String>? onTermsTextChanged;
  final List<SaleFormAttachment> images;
  final List<SaleFormAttachment> documents;
  final VoidCallback? onAddImage;
  final VoidCallback? onAddDocument;
  final ValueChanged<String>? onRemoveImage;
  final ValueChanged<String>? onRemoveDocument;

  @override
  Widget build(BuildContext context) {
    final showNotes = visibility.showDescription || visibility.showTerms;
    final showAttachments = visibility.showAttachments;
    if (!showNotes && !showAttachments) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (visibility.showDescription) ...[
          MobileSaleFormField(
            label: 'Description',
            controller: descriptionController,
            hintText: 'Write your description here',
            minLines: 2,
            maxLines: 4,
            onChanged: onDescriptionChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (visibility.showTerms) ...[
          MobileSalePickerField(
            label: 'Terms & Conditions',
            value: termsTitle ?? 'Sale Invoice',
            onTap: onTermsTitleTap ?? () {},
          ),
          const SizedBox(height: AppSpacing.md),
          MobileSaleFormField(
            label: 'Notes',
            controller: termsTextController,
            hintText: 'Thanks for doing business with us!',
            minLines: 2,
            maxLines: 4,
            onChanged: onTermsTextChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (showAttachments) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddImage,
                  icon: const Icon(LucideIcons.image, size: 18),
                  label: const Text('Add Image'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddDocument,
                  icon: const Icon(LucideIcons.paperclip, size: 18),
                  label: const Text('Add Document'),
                ),
              ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...images.map(
              (attachment) => _AttachmentTile(
                name: attachment.name,
                onRemove: onRemoveImage == null
                    ? null
                    : () => onRemoveImage!(attachment.id),
              ),
            ),
          ],
          if (documents.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...documents.map(
              (attachment) => _AttachmentTile(
                name: attachment.name,
                onRemove: onRemoveDocument == null
                    ? null
                    : () => onRemoveDocument!(attachment.id),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.name, this.onRemove});

  final String name;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(LucideIcons.file, size: 20),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: onRemove == null
          ? null
          : IconButton(
              icon: const Icon(LucideIcons.x, size: 18),
              onPressed: onRemove,
              color: AppColors.textSecondary,
            ),
    );
  }
}

Future<String?> pickMobileTermsTitle(
  BuildContext context, {
  String? selected,
}) {
  return showMobileOptionSheet<String>(
    context: context,
    title: 'Terms Title',
    selected: selected,
    options: [
      for (final title in SaleDropdownOptions.termsTitles)
        MobileOption(value: title, label: title),
    ],
  );
}
