import 'dart:async';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/party_ledger_pdf_builder.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/shared/utils/output_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared party-ledger print — native print on mobile, preview on desktop.
abstract final class PartyLedgerPrintActions {
  static Future<void> previewLedger({
    required BuildContext context,
    required WidgetRef ref,
    required PartyModel party,
    required List<PartyLedgerTransactionModel> transactions,
    double? outstanding,
    double? creditLimit,
  }) async {
    final businessName = ref.read(sidebarBusinessProvider).name;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final bytes = await PartyLedgerPdfBuilder.build(
        party: party,
        transactions: transactions,
        businessName: businessName,
        outstanding: outstanding ?? party.balance,
        creditLimit: creditLimit,
      );
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      final safeName = party.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
      final document = PrintablePdf(
        bytes: bytes,
        name: 'Party_Ledger_$safeName',
        profile: PdfPageProfile.transactionCompact,
      );
      final output = PrintOutputService();
      if (AppPlatform.current.isMobile) {
        await output.printToDevice(context: context, document: document);
      } else {
        await output.previewDocument(context, document);
      }
    } on Object catch (error) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(OutputErrorMapper.printMessage(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
