import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/providers/job_work_out_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class JobWorkOutFooter extends ConsumerWidget {
  const JobWorkOutFooter({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(jobWorkOutFormProvider);
    final notifier = ref.read(jobWorkOutFormProvider.notifier);
    final grandTotal = ref.watch(jobWorkOutGrandTotalProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SaleFormAttachmentsSection(
            description: form.description,
            images: form.attachedImages,
            documents: form.attachedDocuments,
            onDescriptionChanged: notifier.updateDescription,
            onAddImage: () => _promptAddImage(
              context,
              notifier,
              form.attachedImages.length,
            ),
            onRemoveImage: notifier.removeImage,
            onUpdateImage: notifier.updateImage,
            onAddDocument: () => _promptAddDocument(
              context,
              notifier,
              form.attachedDocuments.length,
            ),
            onRemoveDocument: notifier.removeDocument,
            onUpdateDocument: notifier.updateDocument,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currencyFormat.format(grandTotal),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _promptAddImage(
    BuildContext context,
    JobWorkOutFormNotifier notifier,
    int currentCount,
  ) async {
    final attachment = await promptSaleFormAttachment(
      context,
      title: 'Add image',
      defaultName: 'image_${currentCount + 1}.png',
    );
    if (attachment != null) notifier.addImage(attachment);
  }

  Future<void> _promptAddDocument(
    BuildContext context,
    JobWorkOutFormNotifier notifier,
    int currentCount,
  ) async {
    final attachment = await promptSaleFormAttachment(
      context,
      title: 'Add document',
      defaultName: 'document_${currentCount + 1}.pdf',
    );
    if (attachment != null) notifier.addDocument(attachment);
  }
}
