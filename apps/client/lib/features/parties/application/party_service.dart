import 'dart:async';

import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/data/party_cache.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:billing_baba/features/parties/models/delete_status_dto.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_list_query.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

export 'party_error_mapper.dart'
    show
        PartyBusinessNotSelectedException,
        PartyException,
        PartyHasDependenciesException,
        PartyOfflineException;

part 'party_service.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
Future<PartyService> partyService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  return PartyService(
    repository: PartyRepository(api.dio),
    cache: PartyCache(storage),
  );
}

class PartyService {
  PartyService({
    required this._repository,
    required this._cache,
  });

  final PartyRepository _repository;
  final PartyCache _cache;

  bool _isShowingCachedData = false;
  bool get isShowingCachedData => _isShowingCachedData;

  String? get _businessId => _cache.readBusinessId();

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

    try {
      final remote = await _fetchRemoteParties(
        searchQuery: searchQuery,
        filter: filter,
        typeFilter: typeFilter,
      );
      await _persistParties(businessId, remote);
      final merged = await _mergeWithExtensions(businessId, remote);
      return _applyClientFilters(
        merged,
        searchQuery,
        filter,
        typeFilter,
      );
    } on DioException catch (e) {
      final cached = await _loadFromCache(businessId);
      if (cached.isNotEmpty) {
        _isShowingCachedData = true;
        return _applyClientFilters(
          cached,
          searchQuery,
          filter,
          typeFilter,
        );
      }
      PartyErrorMapper.mapAndThrow(e);
    }
  }

  Future<PartyModel> getParty(String partyId) async {
    final businessId = _requireBusinessId();

    final cachedParties = await _loadFromCache(businessId);
    final cached = cachedParties
        .where((party) => party.id == partyId)
        .firstOrNull;
    if (cached != null) {
      unawaited(_fetchPartyInBackground(businessId, partyId));
      return cached;
    }

    try {
      final dto = await _repository.getParty(partyId);
      await _cache.upsertParty(businessId, dto.toJson());
      return _dtoToModel(businessId, dto);
    } on DioException catch (e) {
      PartyErrorMapper.mapAndThrow(e);
    }
  }

  Future<PartyModel> createParty(AddPartyResult result) async {
    final businessId = _requireBusinessId();
    final request = PartyModel.createRequestFromResult(result);
    final extension = PartyLocalExtension.fromAddPartyResult(result);

    try {
      await _syncPendingOperations();
      final created = await _repository.createParty(request);
      await _cache.upsertLocalExtension(businessId, created.id, extension);
      await _cache.upsertParty(businessId, created.toJson());
      return PartyModel.fromDto(created, extension: extension);
    } on DioException catch (e) {
      final validation = ApiErrorParser.parseValidation(e);
      if (validation != null) throw validation;

      if (_isOffline(e)) {
        final localId = _uuid.v4();
        await _cache.queuePendingOperation(businessId, {
          'type': 'create',
          'local_id': localId,
          'request': request.toJson(),
          'extension': extension.toJson(),
        });
        await _cache.upsertLocalExtension(businessId, localId, extension);

        final offlineDto = PartyDto(
          id: localId,
          name: result.partyName.trim(),
          mobile: PartyModel.normalizePhone(result.phone),
          email: result.email.trim().isEmpty ? null : result.email.trim(),
          partyType: result.partyType,
          pricingTier: 'tier_1',
          gstin: result.gstin.trim().isEmpty ? null : result.gstin.trim(),
          state: result.state.trim().isEmpty ? null : result.state.trim(),
          creditLimit: result.hasCustomCreditLimit ? result.creditLimit : '0',
          openingBalance: result.openingBalance.trim().isEmpty
              ? '0'
              : result.openingBalance.trim(),
          balance: result.openingBalance.trim().isEmpty
              ? '0'
              : result.openingBalance.trim(),
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _cache.upsertParty(businessId, offlineDto.toJson());
        throw const PartyOfflineException();
      }
      PartyErrorMapper.mapAndThrow(e);
    }
  }

  Future<PartyModel> updateParty(
    String partyId,
    AddPartyResult result, {
    bool? isActive,
  }) async {
    final businessId = _requireBusinessId();
    final request = PartyModel.updateRequestFromResult(
      result,
      isActive: isActive,
    );
    final extension = PartyLocalExtension.fromAddPartyResult(result);

    try {
      await _syncPendingOperations();
      final updated = await _repository.updateParty(partyId, request);
      await _cache.upsertLocalExtension(businessId, partyId, extension);
      await _cache.upsertParty(businessId, updated.toJson());
      return PartyModel.fromDto(updated, extension: extension);
    } on DioException catch (e) {
      final validation = ApiErrorParser.parseValidation(e);
      if (validation != null) throw validation;

      if (_isOffline(e)) {
        await _cache.queuePendingOperation(businessId, {
          'type': 'update',
          'party_id': partyId,
          'request': request.toJson(),
          'extension': extension.toJson(),
        });
        await _cache.upsertLocalExtension(businessId, partyId, extension);
        throw const PartyOfflineException();
      }
      PartyErrorMapper.mapAndThrow(e);
    }
  }

  Future<PartyModel> setPartyActive(
    String partyId, {
    required bool isActive,
  }) async {
    final businessId = _requireBusinessId();
    final request = UpdatePartyRequest(isActive: isActive);

    try {
      await _syncPendingOperations();
      final updated = await _repository.updateParty(partyId, request);
      await _cache.upsertParty(businessId, updated.toJson());
      return await _dtoToModel(businessId, updated);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        await _cache.queuePendingOperation(businessId, {
          'type': 'update',
          'party_id': partyId,
          'request': request.toJson(),
        });
        final cachedParties = await _loadFromCache(businessId);
        final cached = cachedParties
            .where((party) => party.id == partyId)
            .firstOrNull;
        if (cached != null) {
          final offlineParty = cached.copyWith(
            isActive: isActive,
            updatedAt: DateTime.now(),
          );
          await _cache.upsertParty(
            businessId,
            PartyDto(
              id: offlineParty.id,
              name: offlineParty.name,
              mobile: PartyModel.normalizePhone(offlineParty.phone),
              email: offlineParty.email.isEmpty ? null : offlineParty.email,
              partyType: offlineParty.partyType,
              pricingTier: 'tier_1',
              gstin: offlineParty.gstin.isEmpty ? null : offlineParty.gstin,
              state: offlineParty.state.isEmpty ? null : offlineParty.state,
              creditLimit: offlineParty.hasCustomCreditLimit
                  ? offlineParty.creditLimit
                  : '0',
              openingBalance: offlineParty.openingBalance.toString(),
              balance: offlineParty.balance.toString(),
              isActive: isActive,
              createdAt:
                  offlineParty.createdAt?.toIso8601String() ??
                  DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ).toJson(),
          );
          return offlineParty;
        }
        throw const PartyOfflineException();
      }
      PartyErrorMapper.mapAndThrow(e);
    }
  }

  /// Upgrades customer-only parties so they can be used on purchase documents.
  Future<void> ensureSupplierRole(String partyId) async {
    final businessId = _requireBusinessId();
    final party = await getParty(partyId);
    if (party.partyType == 'supplier' || party.partyType == 'both') {
      return;
    }

    try {
      await _syncPendingOperations();
      final updated = await _repository.updateParty(
        partyId,
        const UpdatePartyRequest(partyType: 'both'),
      );
      await _cache.upsertParty(businessId, updated.toJson());
    } on DioException catch (e) {
      PartyErrorMapper.mapAndThrow(e);
    }
  }

  Future<PartyDeleteAction> deleteParty(String partyId) async {
    final businessId = _requireBusinessId();

    try {
      try {
        await _syncPendingOperations();
      } on Object {
        // Do not block delete when pending sync fails.
      }
      final action = await _repository.deleteParty(partyId);
      if (action == PartyDeleteAction.deleted) {
        await _cache.removeLocalExtension(businessId, partyId);
        await _cache.removeParty(businessId, partyId);
      } else {
        final cachedParties = await _loadFromCache(businessId);
        final cached = cachedParties
            .where((party) => party.id == partyId)
            .firstOrNull;
        if (cached != null) {
          final inactiveParty = cached.copyWith(
            isActive: false,
            updatedAt: DateTime.now(),
          );
          await _cache.upsertParty(
            businessId,
            PartyDto(
              id: inactiveParty.id,
              name: inactiveParty.name,
              mobile: PartyModel.normalizePhone(inactiveParty.phone),
              email: inactiveParty.email.isEmpty ? null : inactiveParty.email,
              partyType: inactiveParty.partyType,
              pricingTier: 'tier_1',
              gstin: inactiveParty.gstin.isEmpty ? null : inactiveParty.gstin,
              state: inactiveParty.state.isEmpty ? null : inactiveParty.state,
              creditLimit: inactiveParty.hasCustomCreditLimit
                  ? inactiveParty.creditLimit
                  : '0',
              openingBalance: inactiveParty.openingBalance.toString(),
              balance: inactiveParty.balance.toString(),
              isActive: false,
              createdAt:
                  inactiveParty.createdAt?.toIso8601String() ??
                  DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ).toJson(),
          );
        }
      }
      return action;
    } on DioException catch (e) {
      if (_isOffline(e)) {
        await _cache.queuePendingOperation(businessId, {
          'type': 'delete',
          'party_id': partyId,
        });
        throw const PartyOfflineException();
      }
      PartyErrorMapper.mapAndThrow(e);
    }
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

  Future<void> _fetchPartyInBackground(
    String businessId,
    String partyId,
  ) async {
    try {
      final dto = await _repository.getParty(partyId);
      await _cache.upsertParty(businessId, dto.toJson());
    } on DioException {
      // Keep cached detail; avoid touching partyDetailProvider during its build.
    }
  }

  /// Writes profile image fields into the local party cache so detail reloads
  /// do not flash back to a missing avatar after upload.
  Future<void> persistPartyProfileImage(
    String partyId, {
    String? profileImageUrl,
    String? profileMediaAssetId,
  }) async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;

    final parties = await _cache.readParties(businessId);
    if (parties.isEmpty) return;

    final next = parties.map((json) {
      if (json['id'] != partyId) return json;
      return {
        ...json,
        'profile_image_url': profileImageUrl,
        'profile_media_asset_id': profileMediaAssetId,
      };
    }).toList();

    await _cache.saveParties(businessId, next);
  }

  Future<List<PartyDto>> _fetchRemoteParties({
    String? searchQuery,
    PartyListFilter filter = PartyListFilter.all,
    PartyTypeFilter typeFilter = PartyTypeFilter.all,
  }) async {
    // Split multi-word queries into individual words.
    // Backend does single-substring ILIKE, so "distributor b" won't match
    // "Britannia Distributor". We fetch results for each word separately,
    // then intersect by id so only parties matching ALL words are returned.
    final words = searchQuery?.trim().split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList() ??
        [];

    // Single word or empty — use existing single-fetch logic
    if (words.length <= 1) {
      return _fetchAllPages(
        searchQuery: words.isEmpty ? null : words.first,
        filter: filter,
      );
    }

    // Multi-word: fetch each word independently, then intersect results
    final wordResults = await Future.wait(
      words.map(
        (word) => _fetchAllPages(searchQuery: word, filter: filter),
      ),
    );

    // Start with the first word's result set
    final firstIds = wordResults.first.map((p) => p.id).toSet();

    // Keep only parties whose id appears in every word's result set
    final intersectedIds = wordResults.skip(1).fold(
      firstIds,
      (ids, wordParties) {
        final wordIds = wordParties.map((p) => p.id).toSet();
        return ids.intersection(wordIds);
      },
    );

    // Return de-duped parties from the first result set that passed intersection
    final seen = <String>{};
    return wordResults.first
        .where((p) => intersectedIds.contains(p.id) && seen.add(p.id))
        .toList();
  }

  /// Fetches all pages for a single search term from the backend.
  Future<List<PartyDto>> _fetchAllPages({
    String? searchQuery,
    PartyListFilter filter = PartyListFilter.all,
  }) async {
    final allParties = <PartyDto>[];
    var page = 1;
    const limit = 100;
    var total = 0;
    do {
      final response = await _repository.listParties(
        PartyListQuery.fromFilter(
          search: searchQuery,
          filter: filter,
          page: page,
        ).copyWith(limit: limit),
      );
      allParties.addAll(response.parties);
      total = response.total;
      page++;
    } while (allParties.length < total);
    final seen = <String>{};
    allParties.retainWhere((p) => seen.add(p.id));
    return allParties;
  }

  List<PartyModel> _applyClientFilters(
    List<PartyModel> parties,
    String? searchQuery,
    PartyListFilter filter,
    PartyTypeFilter typeFilter,
  ) {
    final query = searchQuery?.trim().toLowerCase() ?? '';
    // Split query into individual words for order-independent matching.
    // e.g. "Delhi ABC" matches "ABC Traders Delhi" because both words are found.
    final queryWords = query.isEmpty
        ? <String>[]
        : query.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    final filtered = parties.where((party) {
      if (!typeFilter.matches(party.partyType)) return false;

      if (queryWords.isNotEmpty) {
        // Build a single searchable string from all party fields
        final searchableText = [
          party.name,
          party.phone,
          party.gstin,
        ].join(' ').toLowerCase();

        // Every word must appear somewhere in the combined text
        final allWordsMatch = queryWords.every(
          searchableText.contains,
        );
        if (!allWordsMatch) return false;
      }

      return switch (filter) {
        PartyListFilter.all => true,
        PartyListFilter.toReceive => party.hasReceivable,
        PartyListFilter.toPay => party.hasPayable,
        PartyListFilter.active => party.isActive,
        PartyListFilter.inactive => !party.isActive,
      };
    }).toList()
      ..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    return filtered;
  }

  Future<List<PartyModel>> _loadFromCache(String businessId) async {
    final cached = await _cache.readParties(businessId);
    if (cached.isEmpty) return [];

    final extensions = await _cache.readLocalExtensions(businessId);
    return cached
        .map(
          (json) => PartyModel.fromDto(
            PartyDto.fromJson(json),
            extension:
                extensions[json['id'] as String] ?? const PartyLocalExtension(),
          ),
        )
        .toList();
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

  Future<void> _persistParties(
    String businessId,
    List<PartyDto> parties,
  ) async {
    await _cache.saveParties(
      businessId,
      parties.map((party) => party.toJson()).toList(),
    );
  }

  Future<void> _syncPendingOperations() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;

    final pending = await _cache.readPendingOperations(businessId);
    if (pending.isEmpty) return;

    for (final operation in pending) {
      final type = operation['type'] as String?;
      switch (type) {
        case 'create':
          final requestJson = Map<String, dynamic>.from(
            operation['request'] as Map,
          );
          final created = await _repository.createParty(
            CreatePartyRequest(
              name: requestJson['name'] as String,
              mobile: requestJson['mobile'] as String?,
              email: requestJson['email'] as String?,
              gstin: requestJson['gstin'] as String?,
              partyType: requestJson['party_type'] as String? ?? 'customer',
              state: requestJson['state'] as String?,
              creditLimit: requestJson['credit_limit']?.toString(),
              openingBalance: requestJson['opening_balance']?.toString(),
              isActive: requestJson['is_active'] as bool? ?? true,
            ),
          );
          final extensionJson = operation['extension'];
          if (extensionJson is Map) {
            await _cache.upsertLocalExtension(
              businessId,
              created.id,
              PartyLocalExtension.fromJson(
                Map<String, dynamic>.from(extensionJson),
              ),
            );
          }
          await _cache.upsertParty(businessId, created.toJson());
        case 'update':
          final partyId = operation['party_id'] as String;
          final requestJson = Map<String, dynamic>.from(
            operation['request'] as Map,
          );
          final updated = await _repository.updateParty(
            partyId,
            UpdatePartyRequest(
              name: requestJson['name'] as String?,
              mobile: requestJson['mobile'] as String?,
              email: requestJson['email'] as String?,
              gstin: requestJson['gstin'] as String?,
              partyType: requestJson['party_type'] as String?,
              state: requestJson['state'] as String?,
              creditLimit: requestJson['credit_limit']?.toString(),
              openingBalance: requestJson['opening_balance']?.toString(),
              isActive: requestJson['is_active'] as bool?,
            ),
          );
          final extensionJson = operation['extension'];
          if (extensionJson is Map) {
            await _cache.upsertLocalExtension(
              businessId,
              partyId,
              PartyLocalExtension.fromJson(
                Map<String, dynamic>.from(extensionJson),
              ),
            );
          }
          await _cache.upsertParty(businessId, updated.toJson());
        case 'delete':
          final partyId = operation['party_id'] as String;
          final action = await _repository.deleteParty(partyId);
          if (action == PartyDeleteAction.deleted) {
            await _cache.removeParty(businessId, partyId);
          } else {
            final cachedParties = await _loadFromCache(businessId);
            final cached = cachedParties
                .where((party) => party.id == partyId)
                .firstOrNull;
            if (cached != null) {
              await _cache.upsertParty(
                businessId,
                PartyDto(
                  id: cached.id,
                  name: cached.name,
                  mobile: PartyModel.normalizePhone(cached.phone),
                  email: cached.email.isEmpty ? null : cached.email,
                  partyType: cached.partyType,
                  pricingTier: 'tier_1',
                  gstin: cached.gstin.isEmpty ? null : cached.gstin,
                  state: cached.state.isEmpty ? null : cached.state,
                  creditLimit: cached.hasCustomCreditLimit
                      ? cached.creditLimit
                      : '0',
                  openingBalance: cached.openingBalance.toString(),
                  balance: cached.balance.toString(),
                  isActive: false,
                  createdAt:
                      cached.createdAt?.toIso8601String() ??
                      DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                ).toJson(),
              );
            }
          }
      }
    }

    await _cache.clearPendingOperations(businessId);
  }

  String _requireBusinessId() {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) {
      throw const PartyBusinessNotSelectedException();
    }
    return businessId;
  }

  bool _isOffline(DioException e) =>
      e.response == null ||
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout;
}

extension on PartyListQuery {
  PartyListQuery copyWith({
    int? page,
    int? limit,
    String? q,
    String? partyType,
    bool? isActive,
    String? sort,
    String? order,
  }) {
    return PartyListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: q ?? this.q,
      partyType: partyType ?? this.partyType,
      isActive: isActive ?? this.isActive,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }
}

@Riverpod(keepAlive: true)
class PartyList extends _$PartyList {
  @override
  Future<List<PartyModel>> build() async {
    ref
      ..watch(partySearchQueryProvider)
      ..watch(partyListFilterProvider)
      ..watch(partyTypeFilterProvider)
      ..watch(partyBackendSearchProvider);

    final service = await ref.watch(partyServiceProvider.future);
    final parties = await service.fetchParties(
      searchQuery: ref.read(partyBackendSearchProvider),
      filter: ref.read(partyListFilterProvider),
      typeFilter: ref.read(partyTypeFilterProvider),
    );

    return parties;
  }

  Future<void> refresh({
    String? searchQuery,
    PartyListFilter? filter,
    PartyTypeFilter? typeFilter,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(partyServiceProvider.future);
      return service.fetchParties(
        searchQuery: searchQuery ?? ref.read(partyBackendSearchProvider),
        filter: filter ?? ref.read(partyListFilterProvider),
        typeFilter: typeFilter ?? ref.read(partyTypeFilterProvider),
      );
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
      refreshAfterPartyMutation(ref, refreshList: false);
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
  }) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final updated = await service.updateParty(
        partyId,
        result,
        isActive: isActive,
      );
      _upsertInState(updated);
      ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
      refreshAfterPartyMutation(ref, refreshList: false);
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
      _upsertInState(updated);
      ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
      refreshAfterPartyMutation(ref, refreshList: false);
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

  /// Optimistically patch profile image fields after upload/delete.
  void patchProfileImage(
    String partyId, {
    String? profileImageUrl,
    String? profileMediaAssetId,
    bool clear = false,
  }) {
    final current = state.asData?.value;
    final existing = current?.where((p) => p.id == partyId).firstOrNull ??
        ref.read(partyDetailProvider(partyId)).asData?.value;
    if (existing == null) return;

    final updated = existing.copyWith(
      profileImageUrl: clear ? null : profileImageUrl,
      profileMediaAssetId: clear ? null : profileMediaAssetId,
      clearProfileImage: clear,
    );
    _upsertInState(updated);
    ref.read(partyDetailProvider(partyId).notifier).setParty(updated);
    unawaited(
      ref.read(partyServiceProvider.future).then(
            (service) => service.persistPartyProfileImage(
              partyId,
              profileImageUrl: updated.profileImageUrl,
              profileMediaAssetId: updated.profileMediaAssetId,
            ),
          ),
    );
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
    final service = await ref.watch(partyServiceProvider.future);
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
