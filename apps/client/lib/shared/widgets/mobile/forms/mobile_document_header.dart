import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_document_visibility.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Header row(s): document number, date, time, optional due/terms/godown/etc.
class MobileDocumentHeader extends StatelessWidget {
  const MobileDocumentHeader({
    required this.visibility,
    super.key,
    this.documentNumberLabel = 'Invoice No.',
    this.documentNumberValue,
    this.documentNumberIsPlaceholder = false,
    this.documentNumberEditable = false,
    this.documentNumberController,
    this.onDocumentNumberChanged,
    this.showInvoiceNumberManualToggle = false,
    this.invoiceNumberManual = false,
    this.onInvoiceNumberManualToggle,
    this.onDocumentNumberTap,
    this.dateLabel = 'Date',
    this.dateValue,
    this.dateIsPlaceholder = false,
    this.onDateTap,
    this.timeLabel = 'Time',
    this.timeValue,
    this.timeIsPlaceholder = false,
    this.onTimeTap,
    this.paymentTermsValue,
    this.onPaymentTermsTap,
    this.dueDateValue,
    this.dueDateIsPlaceholder = true,
    this.onDueDateTap,
    this.stateOfSupplyValue,
    this.onStateOfSupplyTap,
    this.godownValue,
    this.onGodownTap,
    this.eWayBillController,
    this.onEWayBillChanged,
  });

  final MobileDocumentVisibility visibility;
  final String documentNumberLabel;
  final String? documentNumberValue;
  final bool documentNumberIsPlaceholder;
  final bool documentNumberEditable;
  final TextEditingController? documentNumberController;
  final ValueChanged<String>? onDocumentNumberChanged;
  final bool showInvoiceNumberManualToggle;
  final bool invoiceNumberManual;
  final ValueChanged<bool>? onInvoiceNumberManualToggle;
  final VoidCallback? onDocumentNumberTap;
  final String dateLabel;
  final String? dateValue;
  final bool dateIsPlaceholder;
  final VoidCallback? onDateTap;
  final String timeLabel;
  final String? timeValue;
  final bool timeIsPlaceholder;
  final VoidCallback? onTimeTap;
  final String? paymentTermsValue;
  final VoidCallback? onPaymentTermsTap;
  final String? dueDateValue;
  final bool dueDateIsPlaceholder;
  final VoidCallback? onDueDateTap;
  final String? stateOfSupplyValue;
  final VoidCallback? onStateOfSupplyTap;
  final String? godownValue;
  final VoidCallback? onGodownTap;
  final TextEditingController? eWayBillController;
  final ValueChanged<String>? onEWayBillChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visibility.showDocumentNumber)
              Expanded(
                child: documentNumberEditable &&
                        documentNumberController != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MobileSaleFormField(
                              label: documentNumberLabel,
                              controller: documentNumberController,
                              hintText: documentNumberLabel,
                              readOnly: showInvoiceNumberManualToggle &&
                                  !invoiceNumberManual,
                              onChanged: onDocumentNumberChanged,
                            ),
                          ),
                          if (showInvoiceNumberManualToggle) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Padding(
                              padding: const EdgeInsets.only(top: 22),
                              child: Switch(
                                value: invoiceNumberManual,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: onInvoiceNumberManualToggle,
                              ),
                            ),
                          ],
                        ],
                      )
                    : MobileSalePickerField(
                        label: documentNumberLabel,
                        value: documentNumberValue ?? 'Auto',
                        isPlaceholder: documentNumberIsPlaceholder,
                        onTap: onDocumentNumberTap ?? () {},
                      ),
              ),
            if (visibility.showDocumentNumber && visibility.showDate)
              const SizedBox(width: AppSpacing.sm),
            if (visibility.showDate)
              Expanded(
                child: MobileSalePickerField(
                  label: dateLabel,
                  value: dateValue ?? 'Select date',
                  isPlaceholder: dateIsPlaceholder,
                  onTap: onDateTap ?? () {},
                ),
              ),
            if (visibility.showDate && visibility.showTime)
              const SizedBox(width: AppSpacing.sm),
            if (visibility.showTime)
              Expanded(
                child: MobileSalePickerField(
                  label: timeLabel,
                  value: timeValue ?? 'Select time',
                  isPlaceholder: timeIsPlaceholder,
                  onTap: onTimeTap ?? () {},
                ),
              ),
          ],
        ),
        if (visibility.showPaymentTerms || visibility.showDueDate) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (visibility.showPaymentTerms)
                Expanded(
                  child: MobileSalePickerField(
                    label: 'Pmt. Terms',
                    value: paymentTermsValue ?? 'Due on Receipt',
                    onTap: onPaymentTermsTap ?? () {},
                  ),
                ),
              if (visibility.showPaymentTerms && visibility.showDueDate)
                const SizedBox(width: AppSpacing.sm),
              if (visibility.showDueDate)
                Expanded(
                  child: MobileSalePickerField(
                    label: 'Due On',
                    value: dueDateValue ?? 'Select date',
                    isPlaceholder: dueDateIsPlaceholder,
                    trailingIcon: LucideIcons.calendar,
                    onTap: onDueDateTap ?? () {},
                  ),
                ),
            ],
          ),
        ],
        if (visibility.showStateOfSupply || visibility.showGodown) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (visibility.showStateOfSupply)
                Expanded(
                  child: MobileSalePickerField(
                    label: 'State of supply',
                    value: stateOfSupplyValue ?? 'Select state',
                    isPlaceholder:
                        stateOfSupplyValue == null ||
                        stateOfSupplyValue!.trim().isEmpty,
                    onTap: onStateOfSupplyTap ?? () {},
                  ),
                ),
              if (visibility.showStateOfSupply && visibility.showGodown)
                const SizedBox(width: AppSpacing.sm),
              if (visibility.showGodown)
                Expanded(
                  child: MobileSalePickerField(
                    label: 'Godown',
                    value: godownValue ?? 'Main Location',
                    onTap: onGodownTap ?? () {},
                  ),
                ),
            ],
          ),
        ],
        if (visibility.showEWayBill) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'E-Way Bill No.',
            controller: eWayBillController,
            hintText: 'E-Way bill number',
            onChanged: onEWayBillChanged,
          ),
        ],
      ],
    );
  }
}
