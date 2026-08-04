import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/party_ledger_pdf_builder.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum _PartyShareChannel { whatsapp, others }

const _whatsappGreen = Color(0xFF25D366);
const _othersBackground = Color(0xFFE8F4FD);
const _othersText = Color(0xFF455A64);

/// Bottom sheet to send a reminder or statement via WhatsApp or native share.
Future<void> _showPartyShareChannelSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
  required double outstanding,
  required String title,
  required _PartyShareKind kind,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    scrollBody: false,
    title: title,
    builder: (sheetContext) {
      return Row(
        children: [
          Expanded(
            child: _ShareChannelButton(
              label: 'WhatsApp',
              backgroundColor: _whatsappGreen,
              labelColor: Colors.white,
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 28,
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(
                  _dispatch(
                    context: context,
                    ref: ref,
                    party: party,
                    outstanding: outstanding,
                    kind: kind,
                    channel: _PartyShareChannel.whatsapp,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ShareChannelButton(
              label: 'Others',
              backgroundColor: _othersBackground,
              labelColor: _othersText,
              icon: const Icon(
                Icons.ios_share_rounded,
                color: _othersText,
                size: 28,
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(
                  _dispatch(
                    context: context,
                    ref: ref,
                    party: party,
                    outstanding: outstanding,
                    kind: kind,
                    channel: _PartyShareChannel.others,
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showPartySendReminderSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
  required double outstanding,
}) {
  return _showPartyShareChannelSheet(
    context: context,
    ref: ref,
    party: party,
    outstanding: outstanding,
    title: 'Send Reminder',
    kind: _PartyShareKind.reminder,
  );
}

Future<void> showPartySendStatementSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
  required double outstanding,
}) {
  return _showPartyShareChannelSheet(
    context: context,
    ref: ref,
    party: party,
    outstanding: outstanding,
    title: 'Send Statement',
    kind: _PartyShareKind.statement,
  );
}

enum _PartyShareKind { reminder, statement }

Future<void> _dispatch({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
  required double outstanding,
  required _PartyShareKind kind,
  required _PartyShareChannel channel,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  if (kind == _PartyShareKind.reminder && outstanding <= 0) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No outstanding balance for this party')),
    );
    return;
  }

  final phone = PartyModel.normalizePhone(party.phone);
  final message = kind == _PartyShareKind.reminder
      ? _reminderMessage(party: party, outstanding: outstanding)
      : _statementMessage(party: party, outstanding: outstanding);

  try {
    if (kind == _PartyShareKind.statement &&
        channel == _PartyShareChannel.others) {
      await _shareStatementPdf(
        context: context,
        ref: ref,
        party: party,
        outstanding: outstanding,
        text: message,
      );
      return;
    }

    if (channel == _PartyShareChannel.whatsapp) {
      if (phone.length != 10) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Party has no valid phone number')),
        );
        return;
      }
      final uri = Uri.parse(
        'https://wa.me/91$phone?text=${Uri.encodeComponent(message)}',
      );
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
      return;
    }

    await SharePlus.instance.share(ShareParams(text: message));
  } on Object catch (error) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Could not share: $error')),
    );
  }
}

Future<void> _shareStatementPdf({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
  required double outstanding,
  required String text,
}) async {
  final messenger = ScaffoldMessenger.of(context);
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
    final ledger = await ref.read(partyTimelineProvider(party.id).future);
    final businessName = ref.read(sidebarBusinessProvider).name;
    final bytes = await PartyLedgerPdfBuilder.build(
      party: party,
      transactions: ledger.transactions,
      businessName: businessName,
      outstanding: outstanding,
      creditLimit: ledger.summary.creditLimit,
    );
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final safeName = party.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
    await PlatformFileOutput.shareFromTemp(
      filename: 'Party_Statement_$safeName.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
      extension: 'pdf',
    );
  } on Object catch (error) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Could not share statement: $error')),
      );
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

String _reminderMessage({
  required PartyModel party,
  required double outstanding,
}) {
  final amount = PartyModel.formatCurrency(outstanding.abs());
  return 'Dear ${party.name},\n\n'
      'This is a friendly reminder that your outstanding balance of $amount '
      'is pending. Please make the payment at your earliest convenience.\n\n'
      'Thank you.';
}

String _statementMessage({
  required PartyModel party,
  required double outstanding,
}) {
  final amount = PartyModel.displayOutstanding(outstanding);
  return 'Party statement for ${party.name}\n'
      'Outstanding: $amount\n\n'
      'Please find the account statement details.';
}

class _ShareChannelButton extends StatelessWidget {
  const _ShareChannelButton({
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 44, child: Center(child: icon)),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
