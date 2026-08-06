import 'package:billing_baba/core/routing/mobile_document_routes.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opens the full-screen Payment-In form with the party pre-filled.
Future<void> showMobileReceivePaymentSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
}) {
  return context.push(
    MobileDocumentRoutes.addPaymentIn(
      partyId: party.id,
      partyName: party.name,
    ),
  );
}

/// Opens the full-screen Payment-Out form with the party pre-filled.
Future<void> showMobileRecordPaymentSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
}) {
  return context.push(
    MobileDocumentRoutes.addPaymentOut(
      partyId: party.id,
      partyName: party.name,
    ),
  );
}
