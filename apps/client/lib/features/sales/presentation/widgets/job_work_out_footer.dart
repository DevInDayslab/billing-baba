import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/providers/job_work_out_form_provider.dart';
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
        SaleFormAttachmentsSection(
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

  Future<void> _promptAddImage(
    BuildContext context,
    JobWorkOutFormNotifier notifier,
    int currentCount,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image attachments coming soon.')),
    );
  }

  Future<void> _promptAddDocument(
    BuildContext context,
    JobWorkOutFormNotifier notifier,
    int currentCount,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document attachments coming soon.')),
    );
  }
}
