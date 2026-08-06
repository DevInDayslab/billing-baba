import 'dart:async';

import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_mapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void navigateToHomeTransaction(
  BuildContext context,
  MobileHomeTransactionItem item,
) {
  final ledger = item.ledgerTransaction;
  if (ledger != null) {
    navigateToPartyLedgerTransaction(context, ledger);
    return;
  }

  final route = MobileTransactionMapper.homeDetailRouteFor(item);
  if (route != null) {
    unawaited(context.push(route));
  }
}
