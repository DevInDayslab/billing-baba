import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportDataEpochProvider =
    NotifierProvider<ReportDataEpochNotifier, int>(
  ReportDataEpochNotifier.new,
);

class ReportDataEpochNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

void bumpReportDataEpoch(Ref ref) {
  ref.read(reportDataEpochProvider.notifier).bump();
}
