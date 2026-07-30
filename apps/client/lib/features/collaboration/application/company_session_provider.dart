import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanySessionNotifier extends Notifier<CompanySession?> {
  @override
  CompanySession? build() => null;

  void setSession(CompanySession session) => state = session;

  void clear() => state = null;
}

final companySessionProvider =
    NotifierProvider<CompanySessionNotifier, CompanySession?>(
      CompanySessionNotifier.new,
    );
