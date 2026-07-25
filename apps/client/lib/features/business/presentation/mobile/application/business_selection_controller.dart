import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_service.dart';
import 'package:billing_baba/features/collaboration/application/company_session_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI state for the mobile business selection flow.
class MobileBusinessSelectionState {
  const MobileBusinessSelectionState({
    this.selectedId,
    this.isOpening = false,
  });

  final String? selectedId;
  final bool isOpening;

  bool get canContinue => selectedId != null && !isOpening;

  MobileBusinessSelectionState copyWith({
    String? selectedId,
    bool? isOpening,
    bool clearSelection = false,
  }) {
    return MobileBusinessSelectionState(
      selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
      isOpening: isOpening ?? this.isOpening,
    );
  }
}

final mobileBusinessSelectionProvider =
    NotifierProvider<
      MobileBusinessSelectionNotifier,
      MobileBusinessSelectionState
    >(
      MobileBusinessSelectionNotifier.new,
    );

/// Selection + open-company orchestration for the mobile business picker.
class MobileBusinessSelectionNotifier
    extends Notifier<MobileBusinessSelectionState> {
  @override
  MobileBusinessSelectionState build() => const MobileBusinessSelectionState();

  void reset() => state = const MobileBusinessSelectionState();

  void seedInitialSelection(List<CompanyListEntry> entries) {
    if (state.selectedId != null) return;

    final openable = entries.where(_isOpenable).toList();
    if (openable.isEmpty) return;

    final current = openable.where((e) => e.isCurrent).firstOrNull;
    if (current != null) {
      state = state.copyWith(selectedId: current.id);
      return;
    }

    if (openable.length == 1) {
      state = state.copyWith(selectedId: openable.first.id);
    }
  }

  void select(String? id) {
    if (state.isOpening) return;
    state = state.copyWith(selectedId: id);
  }

  CompanyListEntry? selectedEntry(List<CompanyListEntry> entries) {
    final id = state.selectedId;
    if (id == null) return null;
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  Future<String?> openSelectedCompany(List<CompanyListEntry> entries) async {
    final entry = selectedEntry(entries);
    if (entry == null) {
      return 'Select a business to continue.';
    }
    if (!_isOpenable(entry)) {
      return 'This business cannot be opened yet.';
    }

    if (ref.read(businessSessionLoadingProvider) != null) {
      return null;
    }

    state = state.copyWith(isOpening: true);
    try {
      BusinessOpenDebugLog.step('mobile-ui', 'calling openCompany');
      final sessionService = await ref.read(
        companySessionServiceProvider.future,
      );
      await sessionService.openCompany(entry);
      BusinessOpenDebugLog.step('mobile-ui', 'openCompany returned');

      final auth = ref.read(authProvider);
      final session = ref.read(companySessionProvider);
      if (auth.status != AuthStatus.authenticated || session == null) {
        return 'Could not open company. Please try again.';
      }

      ref.invalidate(companyDirectoryProvider);
      return null;
    } on CompanySessionOpenBlocked catch (error) {
      return error.message;
    } on BusinessSelectionFailed catch (error) {
      return error.message;
    } on Object catch (error) {
      return error is DioException
          ? ApiErrorParser.userFacingMessage(error)
          : 'Could not open company. Please try again.';
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isOpening: false);
      }
    }
  }

  bool _isOpenable(CompanyListEntry entry) {
    return !entry.relationship.isPending && !entry.relationship.isExpired;
  }
}
