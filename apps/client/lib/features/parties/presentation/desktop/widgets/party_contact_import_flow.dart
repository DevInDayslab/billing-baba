import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_contact_import_preview_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_contact_import_qr_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> startDesktopPartyContactImport(
  BuildContext context,
  WidgetRef ref,
) async {
  final sessionId = await showPartyContactImportQrDialog(context);
  if (sessionId == null || !context.mounted) return;
  await showPartyContactImportPreviewDialog(
    context,
    ref,
    sessionId: sessionId,
  );
}
