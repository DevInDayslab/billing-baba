import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _menuMinWidth = 220.0;
const _menuItemHeight = 40.0;
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  side: BorderSide(color: Color(0xFFE0E0E0)),
);

/// Conversion target for document interlinking.
class SaleDocumentConversionOption {
  const SaleDocumentConversionOption({
    required this.actionKey,
    required this.label,
    required this.targetType,
  });

  final String actionKey;
  final String label;
  final String targetType;
}

/// Configuration for per-document-type CRUD and conversion actions.
class SaleDocumentActionsConfig {
  const SaleDocumentActionsConfig({
    required this.documentType,
    required this.listScope,
    required this.documentLabel,
    required this.printRequestBuilder,
    this.conversionOptions = const [],
    this.onEdit,
    this.navigateAfterConvert,
  });

  final SalesDocumentType documentType;
  final SalesDocumentListScope listScope;
  final String documentLabel;
  final PrintRequest Function(String documentId) printRequestBuilder;
  final List<SaleDocumentConversionOption> conversionOptions;
  final Future<void> Function(BuildContext context, WidgetRef ref, String id)?
  onEdit;
  final String? Function(String targetType)? navigateAfterConvert;

  static SaleDocumentActionsConfig saleOrder({
    required Future<void> Function(BuildContext, WidgetRef, String) onEdit,
  }) {
    return SaleDocumentActionsConfig(
      documentType: SalesDocumentType.saleOrder,
      listScope: saleOrderListScope(),
      documentLabel: 'Sale Order',
      printRequestBuilder: PrintRequest.saleOrder,
      conversionOptions: const [
        SaleDocumentConversionOption(
          actionKey: 'convert_to_challan',
          label: 'Convert to Delivery Challan',
          targetType: 'delivery_challan',
        ),
        SaleDocumentConversionOption(
          actionKey: 'convert_to_invoice',
          label: 'Convert to Sale Invoice',
          targetType: 'tax_invoice',
        ),
      ],
      onEdit: onEdit,
      navigateAfterConvert: (target) => switch (target) {
        'delivery_challan' => AppRoutes.saleDeliveryChallan,
        'tax_invoice' => AppRoutes.saleInvoices,
        _ => null,
      },
    );
  }

  static SaleDocumentActionsConfig deliveryChallan({
    required Future<void> Function(BuildContext, WidgetRef, String) onEdit,
  }) {
    return SaleDocumentActionsConfig(
      documentType: SalesDocumentType.deliveryChallan,
      listScope: deliveryChallanListScope(),
      documentLabel: 'Delivery Challan',
      printRequestBuilder: PrintRequest.deliveryChallan,
      conversionOptions: const [
        SaleDocumentConversionOption(
          actionKey: 'convert_to_invoice',
          label: 'Convert to Sale Invoice',
          targetType: 'tax_invoice',
        ),
      ],
      onEdit: onEdit,
      navigateAfterConvert: (_) => AppRoutes.saleInvoices,
    );
  }

  static SaleDocumentActionsConfig salesReturn() {
    return SaleDocumentActionsConfig(
      documentType: SalesDocumentType.salesReturn,
      listScope: salesReturnListScope(),
      documentLabel: 'Credit Note',
      printRequestBuilder: PrintRequest.creditNote,
      onEdit: (context, ref, id) async {
        await context.push('${AppRoutes.editCreditNote}/$id');
      },
    );
  }

  static SaleDocumentActionsConfig proforma({
    required Future<void> Function(BuildContext, WidgetRef, String) onEdit,
  }) {
    return SaleDocumentActionsConfig(
      documentType: SalesDocumentType.estimate,
      listScope: proformaListScope(),
      documentLabel: 'Proforma Invoice',
      printRequestBuilder: PrintRequest.proformaInvoice,
      conversionOptions: const [
        SaleDocumentConversionOption(
          actionKey: 'convert_to_order',
          label: 'Convert to Sale Order',
          targetType: 'sale_order',
        ),
        SaleDocumentConversionOption(
          actionKey: 'convert_to_challan',
          label: 'Convert to Delivery Challan',
          targetType: 'delivery_challan',
        ),
        SaleDocumentConversionOption(
          actionKey: 'convert_to_invoice',
          label: 'Convert to Sale Invoice',
          targetType: 'tax_invoice',
        ),
      ],
      onEdit: onEdit,
      navigateAfterConvert: (target) => switch (target) {
        'sale_order' => AppRoutes.saleOrder,
        'delivery_challan' => AppRoutes.saleDeliveryChallan,
        'tax_invoice' => AppRoutes.saleInvoices,
        _ => null,
      },
    );
  }
}

class SaleDocumentActionsMenuButton extends ConsumerWidget {
  const SaleDocumentActionsMenuButton({
    required this.document,
    required this.config,
    super.key,
  });

  final SaleInvoiceModel document;
  final SaleDocumentActionsConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (buttonContext) {
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'More',
          icon: const Icon(
            Icons.more_vert,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _openMenu(buttonContext, ref),
        );
      },
    );
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) async {
    final action = await showMenu<String>(
      context: context,
      useRootNavigator: true,
      position: _menuPosition(context),
      color: AppColors.surface,
      shadowColor: Colors.black26,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: _menuShape,
      constraints: const BoxConstraints(minWidth: _menuMinWidth),
      items: SaleDocumentTableActions.buildMenuItems(document, config),
    );

    if (action == null || !context.mounted) return;
    await SaleDocumentTableActions.handleAction(
      context,
      ref,
      document,
      config,
      action,
    );
  }

  static RelativeRect _menuPosition(BuildContext context) {
    final buttonBox = context.findRenderObject()! as RenderBox;
    final overlayBox =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()!
            as RenderBox;

    final buttonOrigin = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonSize = buttonBox.size;

    final menuLeft = (buttonOrigin.dx + buttonSize.width - _menuMinWidth).clamp(
      0.0,
      overlayBox.size.width - _menuMinWidth,
    );
    final menuTop = buttonOrigin.dy + buttonSize.height + 4;

    return RelativeRect.fromLTRB(
      menuLeft,
      menuTop,
      overlayBox.size.width - menuLeft - _menuMinWidth,
      overlayBox.size.height - menuTop,
    );
  }
}

class SaleDocumentTableActions {
  const SaleDocumentTableActions._();

  static List<PopupMenuEntry<String>> buildMenuItems(
    SaleInvoiceModel document,
    SaleDocumentActionsConfig config,
  ) {
    final canConvert =
        document.documentStatus == SalesDocumentStatus.finalized &&
        config.conversionOptions.isNotEmpty;

    return [
      _menuItem('view_edit', 'View/Edit'),
      if (canConvert)
        for (final option in config.conversionOptions)
          _menuItem(option.actionKey, option.label),
      _menuItem('open_pdf', 'Open PDF'),
      _menuItem('preview', 'Preview'),
      _menuItem('print', 'Print'),
      if (!document.isDraft && !document.isCancelled)
        _menuItem('cancel', 'Cancel'),
      _menuItem('delete', 'Delete'),
      if (document.isDraft) _menuItem('finalize', 'Finalize'),
    ];
  }

  static PopupMenuItem<String> _menuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: _menuItemHeight,
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }

  static Future<void> handleAction(
    BuildContext context,
    WidgetRef ref,
    SaleInvoiceModel document,
    SaleDocumentActionsConfig config,
    String action,
  ) async {
    final notifier = ref.read(
      salesDocumentsListProvider(config.listScope).notifier,
    );
    final filename = DocumentPrintActions.filenameFor(document.invoiceNo);
    final printRequest = config.printRequestBuilder(document.id);

    switch (action) {
      case 'view_edit':
        if (config.onEdit != null) {
          await config.onEdit!(context, ref, document.id);
        }
      case 'open_pdf':
      case 'preview':
        await DocumentPrintActions.preview(
          context,
          ref,
          printRequest,
          filename: filename,
        );
      case 'print':
        await DocumentPrintActions.print(
          context,
          ref,
          printRequest,
          filename: filename,
        );
      case 'cancel':
        await _confirmCancel(context, document, config, notifier);
      case 'delete':
        await _confirmDelete(context, document, config, notifier);
      case 'finalize':
        final error = await notifier.finalizeDocument(document.id);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      default:
        final conversion = config.conversionOptions
            .where((option) => option.actionKey == action)
            .firstOrNull;
        if (conversion != null) {
          await _convert(
            context,
            notifier,
            config,
            document.id,
            conversion.targetType,
          );
        }
    }
  }

  static Future<void> _convert(
    BuildContext context,
    SalesDocumentsList notifier,
    SaleDocumentActionsConfig config,
    String documentId,
    String targetType,
  ) async {
    final error = await notifier.convertDocument(
      documentId,
      targetType: targetType,
    );
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${config.documentLabel} converted successfully'),
      ),
    );

    final route = config.navigateAfterConvert?.call(targetType);
    if (route != null && context.mounted) {
      context.go(route);
    }
  }

  static Future<void> _confirmCancel(
    BuildContext context,
    SaleInvoiceModel document,
    SaleDocumentActionsConfig config,
    SalesDocumentsList notifier,
  ) async {
    if (document.isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only finalized ${config.documentLabel.toLowerCase()}s can be cancelled',
          ),
        ),
      );
      return;
    }
    if (document.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This ${config.documentLabel.toLowerCase()} is already cancelled',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel ${config.documentLabel.toLowerCase()}?'),
        content: Text(
          'Cancel ${config.documentLabel.toLowerCase()} ${document.invoiceNo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await notifier.cancelDocument(document.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${config.documentLabel} ${document.invoiceNo} cancelled',
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    SaleInvoiceModel document,
    SaleDocumentActionsConfig config,
    SalesDocumentsList notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${config.documentLabel.toLowerCase()}?'),
        content: Text(
          'Delete ${config.documentLabel.toLowerCase()} ${document.invoiceNo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await notifier.deleteDraft(document.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${config.documentLabel} ${document.invoiceNo} deleted'),
      ),
    );
  }
}
