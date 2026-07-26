import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/shared/utils/debouncer.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:flutter/material.dart';

/// Shared invoice content toggles used by thermal and regular panels.
class CommonInvoiceToggles extends StatefulWidget {
  const CommonInvoiceToggles({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final PrintSettings settings;
  final ValueChanged<PrintSettingsUpdater> onUpdate;

  @override
  State<CommonInvoiceToggles> createState() => _CommonInvoiceTogglesState();
}

class _CommonInvoiceTogglesState extends State<CommonInvoiceToggles> {
  late final TextEditingController _termsController;
  final _termsDebouncer = Debouncer();

  static final _termsFieldDecoration = InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.all(AppSpacing.sm),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: listPanelCardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: listPanelCardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    hintText: 'e.g. Thanks for your business!',
    hintStyle: AppTypography.inter(
      color: AppColors.textSecondary,
      fontSize: AppTypography.bodySmallSize,
    ),
    filled: true,
    fillColor: AppColors.background,
  );

  @override
  void initState() {
    super.initState();
    _termsController = TextEditingController(
      text: widget.settings.termsAndConditions,
    );
  }

  @override
  void didUpdateWidget(CommonInvoiceToggles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.termsAndConditions !=
            widget.settings.termsAndConditions &&
        _termsController.text != widget.settings.termsAndConditions) {
      _termsController.text = widget.settings.termsAndConditions;
    }
  }

  @override
  void dispose() {
    _termsDebouncer.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _update(PrintSettingsUpdater updater) {
    widget.onUpdate(updater);
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'INVOICE CONTENT',
            style: ListPanelStyles.listHeaderStyle,
          ),
        ),
        _ToggleRow(
          label: 'Print Company Name',
          value: settings.printCompanyName,
          onChanged: (value) =>
              _update((s) => s.copyWith(printCompanyName: value)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: listPanelCardBorder,
        ),
        _ToggleRow(
          label: 'Print Company Logo',
          value: settings.printCompanyLogo,
          onChanged: (value) =>
              _update((s) => s.copyWith(printCompanyLogo: value)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: listPanelCardBorder,
        ),
        _ToggleRow(
          label: 'Print Address',
          value: settings.printAddress,
          onChanged: (value) => _update((s) => s.copyWith(printAddress: value)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: listPanelCardBorder,
        ),
        _ToggleRow(
          label: 'Print Phone',
          value: settings.printPhone,
          onChanged: (value) => _update((s) => s.copyWith(printPhone: value)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: listPanelCardBorder,
        ),
        _ToggleRow(
          label: 'Print GSTIN',
          value: settings.printGstin,
          onChanged: (value) => _update((s) => s.copyWith(printGstin: value)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: listPanelCardBorder,
        ),
        _ToggleRow(
          label: 'Print Bank Details',
          value: settings.printBankDetails,
          onChanged: (value) =>
              _update((s) => s.copyWith(printBankDetails: value)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: listPanelCardBorder,
        ),
        _ToggleRow(
          label: 'Print Terms',
          value: settings.printTermsAndConditions,
          onChanged: (value) =>
              _update((s) => s.copyWith(printTermsAndConditions: value)),
        ),
        if (settings.printTermsAndConditions) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _termsController,
            maxLines: 3,
            style: AppTypography.inter(
              fontSize: AppTypography.bodySmallSize,
              color: AppColors.textPrimary,
            ),
            decoration: _termsFieldDecoration,
            onChanged: (value) {
              _termsDebouncer.run(() {
                _update((s) => s.copyWith(termsAndConditions: value));
              });
            },
          ),
        ],
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
