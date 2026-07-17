import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsNavIntentProvider =
    NotifierProvider<ReportsNavIntentNotifier, ReportsNavIntent?>(
  ReportsNavIntentNotifier.new,
);

class ReportsNavIntentNotifier extends Notifier<ReportsNavIntent?> {
  @override
  ReportsNavIntent? build() => null;

  void setIntent(ReportsNavIntent intent) => state = intent;

  ReportsNavIntent? consume() {
    final current = state;
    state = null;
    return current;
  }
}
