import 'package:billing_baba/features/loans/application/loan_providers.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active loan accounts from local Drift cache (sync + hydration).
final loanReportAccountsProvider = Provider<AsyncValue<List<LoanAccountDto>>>((ref) {
  return ref.watch(loanAccountsStreamProvider);
});
