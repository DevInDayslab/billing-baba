import 'dart:async';

import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/data/party_cache.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
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
    show PartyException, PartyHasDependenciesException, PartyOfflineException;

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

  Future<void> deleteParty(String partyId) async {
    final businessId = _requireBusinessId();

    try {
      try {
        await _syncPendingOperations();
      } on Object {
        // Do not block delete when pending sync fails.
      }
      await _repository.deleteParty(partyId);
      await _cache.removeLocalExtension(businessId, partyId);
      await _cache.removeParty(businessId, partyId);
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

  Future<List<PartyDto>> _fetchRemoteParties({
    String? searchQuery,
    PartyListFilter filter = PartyListFilter.all,
    PartyTypeFilter typeFilter = PartyTypeFilter.all,
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

    return allParties;
  }

  List<PartyModel> _applyClientFilters(
    List<PartyModel> parties,
    String? searchQuery,
    PartyListFilter filter,
    PartyTypeFilter typeFilter,
  ) {
    final query = searchQuery?.trim().toLowerCase() ?? '';

    final filtered = parties.where((party) {
      if (!typeFilter.matches(party.partyType)) return false;

      if (query.isNotEmpty) {
        final matchesName = party.name.toLowerCase().contains(query);
        final matchesPhone = party.phone.toLowerCase().contains(query);
        final matchesGstin = party.gstin.toLowerCase().contains(query);
        if (!matchesName && !matchesPhone && !matchesGstin) return false;
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
          await _repository.deleteParty(partyId);
          await _cache.removeParty(businessId, partyId);
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

  Future<PartyModel> createParty(AddPartyResult result) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      final created = await service.createParty(result);
      _upsertInState(created);
      ref.read(selectedPartyIdProvider.notifier).selected = created.id;
      await service.rememberSelectedParty(created.id);
      ref.read(partyDetailProvider(created.id).notifier).setParty(created);
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
      return updated;
    } on PartyOfflineException {
      await refresh();
      rethrow;
    }
  }

  Future<void> deleteParty(String partyId) async {
    final service = await ref.read(partyServiceProvider.future);
    try {
      await service.deleteParty(partyId);
      _removeFromState(partyId);
      ref.invalidate(partyDetailProvider(partyId));
      final selectedId = ref.read(selectedPartyIdProvider);
      if (selectedId == partyId) {
        ref.read(selectedPartyIdProvider.notifier).selected = null;
        await service.rememberSelectedParty(null);
      }
      await refresh();
    } on PartyOfflineException {
      _removeFromState(partyId);
      ref.invalidate(partyDetailProvider(partyId));
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

  void _upsertInState(PartyModel party) {
    final current = state.asData?.value;
    if (current == null) return;
    final index = current.indexWhere((item) => item.id == party.id);
    if (index == -1) {
      state = AsyncData([...current, party]);
      return;
    }
    final next = List<PartyModel>.from(current);
    next[index] = party;
    state = AsyncData(next);
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
