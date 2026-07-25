import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/job_work_out_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _summaryBannerColor = Color(0xFFFFF8E1);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        transactionAttachmentsSection(
          context: context,
          ref: ref,
          entityType: DocumentAttachmentEntityType.jobWork.apiValue,
          entityId: form.orderId,
          description: form.description,
          images: form.attachedImages,
          documents: form.attachedDocuments,
          onDescriptionChanged: notifier.updateDescription,
          addImage: notifier.addImage,
          addDocument: notifier.addDocument,
          removeImage: notifier.removeImage,
          removeDocument: notifier.removeDocument,
          updateImage: notifier.updateImage,
          updateDocument: notifier.updateDocument,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _summaryBannerColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Total Estimated Cost (Raw Material + Additional Cost) = '
              '${_currencyFormat.format(grandTotal)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
