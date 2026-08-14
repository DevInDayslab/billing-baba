import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/parties_selection_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/data/party_cache.dart';
import 'package:billing_baba/features/parties/data/party_local_source.dart';
import 'package:billing_baba/features/parties/data/party_master_repository.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:billing_baba/features/parties/models/delete_status_dto.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/parties/utils/party_projected_balance.dart';
import 'package:billing_baba/features/parties/utils/party_search_match.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'party_error_mapper.dart'
    show
        PartyBusinessNotSelectedException,
        PartyException,
        PartyHasDependenciesException,
        PartyOfflineException;

part 'party_service.g.dart';

@Riverpod(keepAlive: true)
Future<PartyService> partyService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueProvider);
  String? deviceId;
  try {
    final identity = await ref.watch(syncDeviceIdentityProvider.future);
    deviceId = await identity.deviceId();
  } on Object {
    deviceId = null;
  }
  // Rebuild only when the selected business changes. Do not watch the full
  // profile AsyncValue — loading flickers would reload parties and surface a
  // false "Business not selected" error.
  ref.watch(currentBusinessProvider);

  String businessIdReader() {
    final fromCurrent = ref.read(currentBusinessProvider)?.id.trim() ?? '';
    if (fromCurrent.isNotEmpty) return fromCurrent;

    final fromProfile =
        ref.read(businessProfileProvider).asData?.value.id.trim() ?? '';
    if (fromProfile.isNotEmpty) return fromProfile;

    return storage.read(StorageKeys.lastOpenedBusinessId)?.trim() ?? '';
  }

  final repository = PartyRepository(api.dio);
  final local = PartyLocalSource(db);
  final master = PartyMasterRepository(
    local: local,
    syncQueue: queue,
    remote: repository,
    businessIdReader: businessIdReader,
    deviceIdReader: () => deviceId,
  );
  return PartyService(
    cache: PartyCache(storage),
    master: master,
    businessIdReader: businessIdReader,
  );
}

class PartyService {
  PartyService({
    required this._cache,
    required this._master,
    required this._businessIdReader,
  });

  final PartyCache _cache;
  final PartyMasterRepository _master;
  final String Function() _businessIdReader;

  bool _isShowingCachedData = false;
  bool get isShowingCachedData => _isShowingCachedData;

  String? get _businessId {
    final businessId = _businessIdReader().trim();
    return businessId.isEmpty ? null : businessId;
  }

  Future<List<PartyModel>> fetchParties({
    String? searchQuery,
    PartyListFilter filter = PartyListFilter.all,
    PartyTypeFilter typeFilter = PartyTypeFilter.all,
  }) async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) {
      throw const PartyBusinessNotSelectedException();
    }

    _isShowingCachedData = false;
    final remote = await _master.listActive();
    final merged = await _mergeWithExtensions(businessId, remote);
    return _applyClientFilters(
      merged,
      searchQuery,
      filter,
      typeFilter,
    );
  }

  Future<PartyModel> getParty(String partyId) async {
    final dto = await _master.getActive(partyId);
    if (dto == null) {
      throw const PartyException('Party not found');
    }
    final row = await _master.local.getById(partyId);
    final businessId = _resolveBusinessId(row?.businessId);
    return _dtoToModel(businessId, dto);
  }

  Future<PartyModel> createParty(AddPartyResult result) async {
    final businessId = _requireBusinessId();
    final request = PartyModel.createRequestFromResult(result);
    final extension = PartyLocalExtension.fromAddPartyResult(result);
    final created = await _master.create(request);
    await _cache.upsertLocalExtension(businessId, created.id, extension);
    return PartyModel.fromDto(created, extension: extension);
  }

  Future<PartyModel> updateParty(
    String partyId,
    AddPartyResult result, {
    bool? isActive,
    PartyModel? seedParty,
  }) async {
    debugPrint(
      '[PartyUpdate] start partyId=$partyId '
      'name="${result.partyName}" phone="${result.phone}" '
      'gstin="${result.gstin}" opening="${result.openingBalance}"',
    );
    await _ensureLocalPartyRow(partyId, seedParty: seedParty);
    final existingRow = await _master.local.getById(partyId);
    debugPrint(
      '[PartyUpdate] localRow '
      'found=${existingRow != null} '
      'rowBusinessId=${existingRow?.businessId} '
      'scoped=${_readScopedBusinessId()}',
    );
    final businessId = _resolveBusinessId(existingRow?.businessId);
    final request = PartyModel.updateRequestFromResult(
      result,
      isActive: isActive,
    );
    debugPrint('[PartyUpdate] request=${request.toJson()}');
    final extension = PartyLocalExtension.fromAddPartyResult(result);
    final updated = await _updateLocalParty(partyId, request);
    await _cache.upsertLocalExtension(businessId, partyId, extension);
    debugPrint(
      '[PartyUpdate] saved id=${updated.id} name=${updated.name} '
      'businessId=$businessId',
    );
    return PartyModel.fromDto(updated, extension: extension);
  }

  Future<void> _ensureLocalPartyRow(
    String partyId, {
    PartyModel? seedParty,
  }) async {
    final existingRow = await _master.local.getById(partyId);
    if (existingRow != null && !existingRow.isDeleted) return;

    if (seedParty != null && seedParty.id == partyId) {
      final businessId = _requireBusinessId();
      await _master.ensureLocalFromModel(businessId, seedParty);
      return;
    }

    final hydrated = await _master.getActive(partyId);
    if (hydrated == null) {
      throw const PartyException('Party not found');
    }
  }

  Future<PartyDto> _updateLocalParty(
    String partyId,
    UpdatePartyRequest request,
  ) async {
    try {
      return await _master.update(partyId, request);
    } on Object catch (error, stack) {
      debugPrint('[PartyUpdate] local persist failed: $error\n$stack');
      throw PartyException(_localPartyPersistMessage(error));
    }
  }

  String _localPartyPersistMessage(Object error) {
    final message = error is StateError ? error.message : error.toString();
    if (message.contains('Party not found locally')) {
      return 'Party not found. Refresh the list and try again.';
    }
    if (message.contains('different business')) {
      return 'This party belongs to another business.';
    }
    if (message.contains('No business selected')) {
      return 'Business not selected. Please select a business first.';
    }
    return message;
  }

  Future<PartyModel> setPartyActive(
    String partyId, {
    required bool isActive,
  }) async {
    final existingRow = await _master.local.getById(partyId);
    final businessId = _resolveBusinessId(existingRow?.businessId);
    final updated = await _master.update(
      partyId,
      UpdatePartyRequest(isActive: isActive),
    );
    return _dtoToModel(businessId, updated);
  }

  Future<PartyModel> updatePartyNotes(String partyId, String? notes) async {
    final existingRow = await _master.local.getById(partyId);
    final businessId = _resolveBusinessId(existingRow?.businessId);
    final updated = await _master.update(
      partyId,
      UpdatePartyRequest(notes: notes),
    );
    return _dtoToModel(businessId, updated);
  }

  /// Upgrades customer-only parties so they can be used on purchase documents.
  Future<void> ensureSupplierRole(String partyId) async {
    final party = await getParty(partyId);
    if (party.partyType == 'supplier' || party.partyType == 'both') {
      return;
    }
    await _master.update(
      partyId,
      const UpdatePartyRequest(partyType: 'both'),
    );
  }

  Future<PartyDeleteAction> deleteParty(String partyId) async {
    final businessId = _requireBusinessId();
    await _master.softDelete(partyId);
    await _cache.removeLocalExtension(businessId, partyId);
    return PartyDeleteAction.deleted;
  }

  Future<void> syncPendingOperations() => _syncPendingOperations();

  Future<void> rememberSelectedParty(String? partyId) async {
    final businessId = _businessId;
    if (businessId == null) return;
    await _cache.saveSelectedPartyId(businessId, partyId);
  }

  String? readRememberedSelectedParty() {
    final businessId = _businessId;
    if (businessId == null) return null;
    return _cache.readSelectedPartyId(businessId);
  }

  Future<void> rememberListFilter(PartyListFilter filter) async {
    final businessId = _businessId;
    if (businessId == null) return;
    await _cache.saveListFilter(businessId, filter.name);
  }

  PartyListFilter? readRememberedListFilter() {
    final businessId = _businessId;
    if (businessId == null) return null;
    final value = _cache.readListFilter(businessId);
    if (value == null) return null;
    return PartyListFilter.values
        .where((filter) => filter.name == value)
        .firstOrNull;
  }

  Future<List<String>> readPartyGroupNames() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return [];
    return _cache.readPartyGroupNames(businessId);
  }

  Future<void> savePartyGroupNames(List<String> names) async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;
    await _cache.savePartyGroupNames(businessId, names);
  }

  /// All locally cached parties with extensions — ignores Parties page filters.
  Future<List<PartyModel>> loadAllCachedParties() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return [];
    return _loadFromCache(businessId);
  }

  /// Cached parties for group discovery; fetches unfiltered when cache is empty.
  Future<List<PartyModel>> loadPartiesForGroupDiscovery() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return [];

    final cached = await _loadFromCache(businessId);
    if (cached.isNotEmpty) return cached;

    try {
      return await fetchParties();
    } on Object {
      return const [];
    }
  }

  /// Writes profile image fields into the local party cache so detail reloads
  /// do not flash back to a missing avatar after upload.
  Future<void> persistPartyProfileImage(
    String partyId, {
    String? profileImageUrl,
    String? profileMediaAssetId,
  }) async {
    final row = await _master.local.getById(partyId);
    if (row == null) return;
    await _master.local.upsertRow(
      id: row.id,
      businessId: row.businessId,
      name: row.name,
      legalName: row.legalName,
      alias: row.alias,
      mobile: row.mobile,
      email: row.email,
      partyGroup: row.partyGroup,
      areaCode: row.areaCode,
      partyType: row.partyType,
      partyCategory: row.partyCategory,
      pricingTier: row.pricingTier,
      gstin: row.gstin,
      stateCode: row.stateCode,
      areaId: row.areaId,
      creditLimit: row.creditLimit,
      openingBalance: row.openingBalance,
      hiddenLedgerBalance: row.hiddenLedgerBalance,
      profileImageUrl: profileImageUrl,
      profileMediaAssetId: profileMediaAssetId,
      connectedSince: row.connectedSince,
      notes: row.notes,
      isActive: row.isActive,
      syncVersion: row.syncVersion,
      createdAt: row.createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: row.deletedAt,
      isDeleted: row.isDeleted,
      deviceId: row.deviceId,
    );
  }

  List<PartyModel> _applyClientFilters(
    List<PartyModel> parties,
    String? searchQuery,
    PartyListFilter filter,
    PartyTypeFilter typeFilter,
  ) {
    final queryWords = PartySearchMatch.queryWords(searchQuery);

    final filtered = parties.where((party) {
      if (!typeFilter.matches(party.partyType)) return false;

      if (queryWords.isNotEmpty) {
        final matches = PartySearchMatch.matchesFields(
          queryWords: queryWords,
          fields: [
            party.name,
            party.legalName,
            party.alias,
            party.additionalField1,
            party.phone,
            ...party.additionalPhones,
            party.gstin,
            party.email,
            party.partyGroup,
          ],
        );
        if (!matches) return false;
      }

      return switch (filter) {
        PartyListFilter.all => true,
        PartyListFilter.toReceive => party.hasReceivable,
        PartyListFilter.toPay => party.hasPayable,
        PartyListFilter.active => party.isActive,
        PartyListFilter.inactive => !party.isActive,
      };
    }).toList()..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    return filtered;
  }

  Future<List<PartyModel>> _loadFromCache(String businessId) async {
    final dtos = await _master.local.listActive(businessId);
    if (dtos.isEmpty) return [];
    return _mergeWithExtensions(businessId, dtos);
  }

  Future<List<PartyModel>> _mergeWithExtensions(
    String businessId,
    List<PartyDto> parties,
  ) async {
    final extensions = await _cache.readLocalExtensions(businessId);
    return parties
        .map(
          (dto) => PartyModel.fromDto(
            dto,
            extension: extensions[dto.id] ?? const PartyLocalExtension(),
          ),
        )
        .toList();
  }

  Future<PartyModel> _dtoToModel(String businessId, PartyDto dto) async {
    final extensions = await _cache.readLocalExtensions(businessId);
    return PartyModel.fromDto(
      dto,
      extension: extensions[dto.id] ?? const PartyLocalExtension(),
    );
  }

  Future<void> _syncPendingOperations() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;
    // Legacy prefs pending-ops retired — master CRUD uses SyncQueue.
    await _cache.clearPendingOperations(businessId);
  }

  String _readScopedBusinessId() {
    try {
      return _businessIdReader().trim();
    } on Object catch (error, stack) {
      debugPrint('[PartyUpdate] businessIdReader failed: $error\n$stack');
      return '';
    }
  }

  String _resolveBusinessId([String? rowBusinessId]) {
    final scoped = _readScopedBusinessId();
    final rowId = rowBusinessId?.trim() ?? '';
    if (rowId.isNotEmpty) {
      if (scoped.isNotEmpty && scoped.toLowerCase() != rowId.toLowerCase()) {
        throw const PartyException(
          'This party belongs to another business.',
        );
      }
      return rowId;
    }
    if (scoped.isNotEmpty) return scoped;
    throw const PartyBusinessNotSelectedException();
  }

  String _requireBusinessId() => _resolveBusinessId();
}

@Riverpod(keepAlive: true)
class PartyList extends _$PartyList {
  @override
  Future<List<PartyModel>> build() async {
    ref.watch(currentBusinessProvider);

    final service = await ref.read(partyServiceProvider.future);
    final filter = ref.read(partyListFilterProvider);
    final fetchFilter =
        filter == PartyListFilter.toReceive || filter == PartyListFilter.toPay
        ? PartyListFilter.all
        : filter;
    final parties = await service.fetchParties(
      searchQuery: ref.read(partyBackendSearchProvider),
      filter: fetchFilter,
      typeFilter: ref.read(partyTypeFilterProvider),
    );

    if (filter == PartyListFilter.toReceive ||
        filter == PartyListFilter.toPay) {
      final ledgerService = await ref.watch(partyLedgerServiceProvider.future);
      final businessId = await ref.watch(partyLedgerBusinessIdProvider.future);
      final outstandingIndex = await ledgerService.fetchOutstandingIndex(
        businessId: businessId,
      );
      return parties.where((party) {
        final balance = projectedPartyBalance(party, outstandingIndex);
        final projected = party.copyWith(balance: balance);
        return switch (filter) {
          PartyListFilter.toReceive => projected.hasReceivable,
          PartyListFilter.toPay => projected.hasPayable,
          _ => true,
        };
      }).toList()..sort(
        (a, b) => projectedPartyBalance(b, outstandingIndex).abs().compareTo(
          projectedPartyBalance(a, outstandingIndex).abs(),
        ),
      );
    }

    return parties;
  }

  Future<void> refresh({
    String? searchQuery,
    PartyListFilter? filter,
    PartyTypeFilter? typeFilter,
  }) async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(partyServiceProvider.future);
      final activeFilter = filter ?? ref.read(partyListFilterProvider)!;
      final fetchFilter =
          activeFilter == PartyListFilter.toReceive ||
              activeFilter == PartyListFilter.toPay
          ? PartyListFilter.all
          : activeFilter;
      final parties = await service.fetchParties(
        searchQuery: searchQuery ?? ref.read(partyBackendSearchProvider),
        filter: fetchFilter,
        typeFilter: typeFilter ?? ref.read(partyTypeFilterProvider),
      );

      if (activeFilter == PartyListFilter.toReceive ||
          activeFilter == PartyListFilter.toPay) {
        final ledgerService = await ref.read(partyLedgerServiceProvider.future);
        final businessId = await ref.read(partyLedgerBusinessIdProvider.future);
        final outstandingIndex = await ledgerService.fetchOutstandingIndex(
          businessId: businessId,
        );
        return parties.where((party) {
          final balance = projectedPartyBalance(party, outstandingIndex);
          final projected = party.copyWith(balance: balance);
          return switch (activeFilter) {
            PartyListFilter.toReceive => projected.hasReceivable,
            PartyListFilter.toPay => projected.hasPayable,
            _ => true,
          };
        }).toList()..sort(
          (a, b) => projectedPartyBalance(b, outstandingIndex).abs().compareTo(
            projectedPartyBalance(a, outstandingIndex).abs(),
          ),
        );
      }

      return parties;
    });
  }

  Future<PartyModel> createParty(
    AddPartyResult result, {
    bool selectCreated = true,
  }) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final created = await service.createParty(result);
      if (!_upsertInState(created)) {
        await refresh();
        _upsertInState(created);
      }
      if (selectCreated) {
        ref.read(selectedPartyIdProvider.notifier).selected = created.id;
        await service.rememberSelectedParty(created.id);
      }
      ref.read(partyDetailProvider(created.id).notifier).setParty(created);
      refreshAfterPartyMutation(ref, refreshList: false, partyId: created.id);
      return created;
    } on PartyOfflineException {
      await refresh();
      rethrow;
    }
  }

  Future<PartyModel> updateParty(
    String partyId,
    AddPartyResult result, {
    bool? isActive,
    PartyModel? seedParty,
  }) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final existing =
          state.asData?.value
              .where((party) => party.id == partyId)
              .firstOrNull ??
          ref.read(partyDetailProvider(partyId)).asData?.value ??
          seedParty;

      var updated = await service.updateParty(
        partyId,
        result,
        isActive: isActive,
        seedParty: seedParty ?? existing,
      );

      // Preserve a just-uploaded profile image if the PATCH response raced
      // ahead of the media bind and came back without it.
      final keepImage = existing?.profileImageUrl;
      final keepMediaId = existing?.profileMediaAssetId;
      final memoryMediaId = keepMediaId?.trim();
      final updatedMediaId = updated.profileMediaAssetId?.trim();

      if (memoryMediaId != null &&
          memoryMediaId.isNotEmpty &&
          memoryMediaId != updatedMediaId) {
        updated = updated.copyWith(
          profileImageUrl: keepImage,
          profileMediaAssetId: keepMediaId,
        );
        try {
          await service.persistPartyProfileImage(
            partyId,
            profileImageUrl: keepImage,
            profileMediaAssetId: keepMediaId,
          );
        } on Object {
          // Image is already bound on the server; local persist is best-effort.
        }
      } else if ((updated.profileImageUrl == null ||
              updated.profileImageUrl!.trim().isEmpty) &&
          keepImage != null &&
          keepImage.trim().isNotEmpty) {
        updated = updated.copyWith(
          profileImageUrl: keepImage,
          profileMediaAssetId: keepMediaId,
        );
        try {
          await service.persistPartyProfileImage(
            partyId,
            profileImageUrl: keepImage,
            profileMediaAssetId: keepMediaId,
          );
        } on Object {
          // Image is already bound on the server; local persist is best-effort.
        }
      }

      try {
        if (!_upsertInState(updated)) {
          await refresh();
          _upsertInState(updated);
        }
        ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
        refreshAfterPartyMutation(ref, refreshList: false, partyId: partyId);
      } on Object catch (error, stack) {
        // Local SQLite write and sync-queue enqueue already succeeded.
        debugPrint('[PartyUpdate] post-save UI refresh failed: $error\n$stack');
      }
      return updated;
    } on PartyOfflineException {
      await refresh();
      rethrow;
    }
  }

  Future<PartyDeleteAction> deleteParty(String partyId) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final action = await service.deleteParty(partyId);
      if (action == PartyDeleteAction.deleted) {
        _removeFromState(partyId);
        ref.invalidate(partyDetailProvider(partyId));
        final selectedId = ref.read(selectedPartyIdProvider);
        if (selectedId == partyId) {
          ref.read(selectedPartyIdProvider.notifier).selected = null;
          await service.rememberSelectedParty(null);
        }
      } else {
        final filter = ref.read(partyListFilterProvider);
        if (filter == PartyListFilter.active) {
          _removeFromState(partyId);
          if (ref.read(selectedPartyIdProvider) == partyId) {
            ref.read(selectedPartyIdProvider.notifier).selected = null;
            await service.rememberSelectedParty(null);
          }
        } else {
          final current = state.asData?.value;
          final existing = current
              ?.where((party) => party.id == partyId)
              .firstOrNull;
          if (existing != null) {
            final updated = existing.copyWith(isActive: false);
            _upsertInState(updated);
            ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
          }
        }
      }
      await refresh();
      return action;
    } on PartyOfflineException {
      _removeFromState(partyId);
      ref.invalidate(partyDetailProvider(partyId));
      rethrow;
    }
  }

  Future<PartyModel> restoreParty(String partyId) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final updated = await service.setPartyActive(partyId, isActive: true);
      if (!_upsertInState(updated)) {
        await refresh();
        _upsertInState(updated);
      }
      ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
      refreshAfterPartyMutation(ref, refreshList: false, partyId: partyId);
      return updated;
    } on PartyOfflineException {
      await refresh();
      rethrow;
    }
  }

  Future<PartyModel> deactivateParty(String partyId) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final updated = await service.setPartyActive(partyId, isActive: false);
      final filter = ref.read(partyListFilterProvider);
      if (filter == PartyListFilter.active) {
        _removeFromState(partyId);
        if (ref.read(selectedPartyIdProvider) == partyId) {
          ref.read(selectedPartyIdProvider.notifier).selected = null;
          await service.rememberSelectedParty(null);
        }
      } else {
        _upsertInState(updated);
      }
      ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
      return updated;
    } on PartyOfflineException {
      await refresh();
      rethrow;
    }
  }

  Future<PartyModel> updatePartyNotes(String partyId, String? notes) async {
    final service = await ref.read(partyServiceProvider.future);
    final updated = await service.updatePartyNotes(partyId, notes);
    _upsertInState(updated);
    ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
    refreshAfterPartyMutation(ref, refreshList: false, partyId: partyId);
    return updated;
  }

  /// Optimistically patch profile image fields after upload/delete.
  Future<void> patchProfileImage(
    String partyId, {
    String? profileImageUrl,
    String? profileMediaAssetId,
    bool clear = false,
  }) async {
    final current = state.asData?.value;
    final existing =
        current?.where((p) => p.id == partyId).firstOrNull ??
        ref.read(partyDetailProvider(partyId)).asData?.value;
    if (existing == null) return;

    final updated = existing.copyWith(
      profileImageUrl: clear ? null : profileImageUrl,
      profileMediaAssetId: clear ? null : profileMediaAssetId,
      clearProfileImage: clear,
    );
    _upsertInState(updated);
    ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
    try {
      final service = await ref.read(partyServiceProvider.future);
      await service.persistPartyProfileImage(
        partyId,
        profileImageUrl: updated.profileImageUrl,
        profileMediaAssetId: updated.profileMediaAssetId,
      );
    } on Object {
      // Keep the in-memory image even if local persist is skipped.
    }
  }

  bool _upsertInState(PartyModel party) {
    final current = state.asData?.value;
    if (current == null) return false;
    final index = current.indexWhere((item) => item.id == party.id);
    if (index == -1) {
      state = AsyncData([...current, party]);
      return true;
    }
    final next = List<PartyModel>.from(current);
    next[index] = party;
    state = AsyncData(next);
    return true;
  }

  void _removeFromState(String partyId) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.where((party) => party.id != partyId).toList(),
    );
  }

  void renamePartyGroup(String oldName, String newName) {
    final parties = state.asData?.value;
    if (parties == null) return;
    state = AsyncData(
      parties
          .map(
            (party) => party.partyGroup == oldName
                ? party.copyWith(partyGroup: newName)
                : party,
          )
          .toList(),
    );
  }

  void clearPartyGroup(String groupName) {
    final parties = state.asData?.value;
    if (parties == null) return;
    state = AsyncData(
      parties
          .map(
            (party) => party.partyGroup == groupName
                ? party.copyWith(partyGroup: '')
                : party,
          )
          .toList(),
    );
  }
}

@Riverpod(keepAlive: true)
class PartyDetail extends _$PartyDetail {
  @override
  Future<PartyModel> build(String partyId) async {
    ref.watch(currentBusinessProvider);
    final service = await ref.read(partyServiceProvider.future);
    return service.getParty(partyId);
  }

  void setParty(PartyModel party) {
    state = AsyncData(party);
  }
}

@Riverpod(keepAlive: true)
class PartyBackendSearch extends _$PartyBackendSearch {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
bool partiesUsingCache(Ref ref) {
  final serviceAsync = ref.watch(partyServiceProvider);
  return serviceAsync.maybeWhen(
    data: (service) => service.isShowingCachedData,
    orElse: () => false,
  );
}
