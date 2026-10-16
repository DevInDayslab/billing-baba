import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_receipt_printer.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/shared/utils/output_error_mapper.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:billing_baba/shared/utils/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

enum PosBillShareOption {
  savePdf,
  whatsApp,
  email,
  moreApps,
}

extension PosBillShareOptionLabels on PosBillShareOption {
  String get title => switch (this) {
    PosBillShareOption.savePdf => 'Save to PDF',
    PosBillShareOption.whatsApp => 'WhatsApp',
    PosBillShareOption.email => 'Email',
    PosBillShareOption.moreApps => 'More apps',
  };

  String get subtitle => switch (this) {
    PosBillShareOption.savePdf => 'Download the bill as a PDF file',
    PosBillShareOption.whatsApp => 'Send the bill PDF via WhatsApp',
    PosBillShareOption.email => 'Open your email app with the bill PDF',
    PosBillShareOption.moreApps =>
      'Share the bill PDF with any app on this device',
  };
}

String posBillShareSummaryText(PosSale sale) {
  final customer = sale.customerName?.trim();
  final lines = <String>[
    'Bill preview',
    if (customer != null && customer.isNotEmpty) 'Customer: $customer',
    'Items: ${sale.itemCount}',
    'Total: ${_currency.format(sale.finalAmount)}',
  ];
  return lines.join('\n');
}

/// Share / save draft POS bills before checkout.
class PosBillShareHandler {
  static Future<void> run({
    required BuildContext context,
    required WidgetRef ref,
    required PosSale sale,
    required PosBillShareOption option,
  }) async {
    final printer = ref.read(posReceiptPrinterProvider);

    try {
      switch (option) {
        case PosBillShareOption.savePdf:
          final path = await printer.savePdf(sale: sale, ref: ref);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                path != null
                    ? 'PDF saved to $path'
                    : 'PDF ready to save',
              ),
            ),
          );
        case PosBillShareOption.whatsApp:
          await _shareWhatsApp(context, ref, sale, printer);
        case PosBillShareOption.email:
          await _shareEmail(context, ref, sale, printer);
        case PosBillShareOption.moreApps:
          await _shareWithSystemSheet(sale, printer, ref);
      }
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OutputErrorMapper.printMessage(error))),
      );
    }
  }

  static Future<void> shareFromCartSession({
    required BuildContext context,
    required WidgetRef ref,
    required String cartSessionKey,
    required PosBillShareOption option,
  }) async {
    final cart = ref.read(posCartProvider(sessionKey: cartSessionKey));
    if (cart.items.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items before sharing')),
      );
      return;
    }
    final sale = posPreviewSaleFromCart(cart);
    await run(context: context, ref: ref, sale: sale, option: option);
  }

  static Future<PartyModel?> _partyForCustomer(
    WidgetRef ref,
    String? customerName,
  ) async {
    final name = customerName?.trim();
    if (name == null || name.isEmpty) return null;
    final parties = await ref.read(partyPickerListProvider.future);
    for (final party in parties) {
      if (party.name.trim() == name) return party;
    }
    return null;
  }

  static Future<void> _shareWithSystemSheet(
    PosSale sale,
    PosReceiptPrinter printer,
    WidgetRef ref,
  ) async {
    final bytes = await printer.generatePdf(sale: sale, ref: ref);
    await PlatformFileOutput.sharePdfFromTemp(
      filename: printer.pdfBasename(sale),
      bytes: bytes,
      text: posBillShareSummaryText(sale),
    );
  }

  static Future<void> _shareEmail(
    BuildContext context,
    WidgetRef ref,
    PosSale sale,
    PosReceiptPrinter printer,
  ) async {
    final bytes = await printer.generatePdf(sale: sale, ref: ref);
    final basename = printer.pdfBasename(sale);
    final summary = posBillShareSummaryText(sale);

    final party = await _partyForCustomer(ref, sale.customerName);
    final to = party?.email.trim();

    final subject = Uri.encodeComponent('Bill preview');
    final body = Uri.encodeComponent(summary);
    final uri = (to != null && to.isNotEmpty)
        ? Uri.parse('mailto:$to?subject=$subject&body=$body')
        : Uri.parse('mailto:?subject=$subject&body=$body');

    if (PlatformFileOutput.isMobile) {
      await PlatformFileOutput.sharePdfFromTemp(
        filename: basename,
        bytes: bytes,
        text: summary,
      );
      return;
    }

    final opened = await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    try {
      await PlatformFileOutput.sharePdfFromTemp(
        filename: basename,
        bytes: bytes,
        text: summary,
      );
    } on Object {
      // Share sheet may be unavailable; mail client may still be open.
    }

    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open an email app. Pick an email app in the '
            'share window, or use Save to PDF.',
          ),
        ),
      );
    }
  }

  static Future<void> _shareWhatsApp(
    BuildContext context,
    WidgetRef ref,
    PosSale sale,
    PosReceiptPrinter printer,
  ) async {
    final bytes = await printer.generatePdf(sale: sale, ref: ref);
    final basename = printer.pdfBasename(sale);
    final summary = posBillShareSummaryText(sale);

    final party = await _partyForCustomer(ref, sale.customerName);
    final waPhone = party == null
        ? null
        : WhatsAppLauncher.digitsForWaMe(
            PartyModel.normalizePhone(party.phone),
          );

    if (PlatformFileOutput.isMobile) {
      await PlatformFileOutput.sharePdfFromTemp(
        filename: basename,
        bytes: bytes,
        text: summary,
      );
      return;
    }

    final opened = await WhatsAppLauncher.openChat(
      message: summary,
      waMePhoneDigits: waPhone,
    );

    try {
      await PlatformFileOutput.sharePdfFromTemp(
        filename: basename,
        bytes: bytes,
        text: summary,
      );
    } on Object {
      // Share sheet may be unavailable; WhatsApp chat may still be open.
    }

    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open WhatsApp. Install WhatsApp Desktop or use '
            'More apps.',
          ),
        ),
      );
    }
  }
}
