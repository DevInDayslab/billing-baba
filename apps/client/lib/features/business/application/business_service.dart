import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/business_selection_retry_guard.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/services/business_local_data_cleanup.dart';
import 'package:billing_baba/core/services/session_cache_cleanup.dart';
import 'package:billing_baba/core/sync/engine/sync_pause_gate.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/models/account_profile.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:billing_baba/features/business/data/business_cache.dart';
import 'package:billing_baba/features/business/data/business_repository.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/business/utils/business_profile_debug_log.dart';
import 'package:billing_baba/core/sync/application/sync_engine_lifecycle_provider.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/data/godown_local_source.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/models/dto/godown_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/shared/utils/jwt_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_service.g.dart';

@Riverpod(keepAlive: true)
Future<BusinessService> businessService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  return BusinessService(
    repository: BusinessRepository(api.dio),
    cache: BusinessCache(storage),
    ref: ref,
  );
}

class BusinessService {
  BusinessService({
    required this._repository,
    required this._cache,
    required this._ref,
  });

  final BusinessRepository _repository;
  final BusinessCache _cache;
  final Ref _ref;

  Future<List<BusinessModel>> fetchBusinesses({
    bool forceRefresh = false,
  }) async {
    final auth = _ref.read(authProvider);
    final session = auth.session;
    final accountId = _businessListCacheAccountId(session);
    final selectedId = authHasBusinessScope(auth)
        ? _cache.readLastOpenedBusinessId()
        : null;

    if (accountId != null && session != null) {
      final cachedAccountId = _cache.readCachedBusinessesAccountId();
      if (cachedAccountId != null &&
          cachedAccountId.isNotEmpty &&
          !JwtUtils.isSameAccountCacheKey(
            cachedAccountId: cachedAccountId,
            sessionUserId: session.user.id,
            accessToken: session.accessToken,
          )) {
        await _cache.clearAll();
      }
    }

    if (!forceRefresh) {
      final cached = await _loadFromCache(selectedId);
      if (cached.isNotEmpty) {
        unawaited(_refreshInBackground(accountId, selectedId));
        return cached;
      }
    }

    try {
      final remote = await _repository.listBusinesses();
      if (accountId != null) {
        await _cache.saveBusinesses(
          remote.map(_businessToJson).toList(),
          accountId: accountId,
        );
      }
      return remote.map((b) => _toModel(b, selectedId)).toList();
    } on DioException {
      final cached = await _loadFromCache(selectedId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  /// Stable SharedPreferences key: JWT `account_id` when present, else user.id.
  String? _businessListCacheAccountId(AuthSession? session) {
    if (session == null) return null;
    final fromJwt = JwtUtils.accountId(session.accessToken);
    if (fromJwt != null && fromJwt.isNotEmpty) return fromJwt;
    final id = session.user.id;
    if (id.isEmpty || id == 'offline') return null;
    return id;
  }

  Future<void> _refreshInBackground(
    String? accountId,
    String? selectedId,
  ) async {
    try {
      final remote = await _repository.listBusinesses();
      if (accountId != null) {
        await _cache.saveBusinesses(
          remote.map(_businessToJson).toList(),
          accountId: accountId,
        );
      }
    } on DioException {
      // Keep showing cache.
    }
  }

  Future<List<BusinessModel>> _loadFromCache(String? selectedId) async {
    final cached = await _cache.readBusinesses();
    return cached
        .map((json) => _toModel(BusinessDetailDto.fromJson(json), selectedId))
        .toList();
  }

  Future<BusinessModel> createBusiness(CreateBusinessRequest request) async {
    try {
      final created = await _repository.createBusiness(request);
      await _syncPendingCreates();
      await fetchBusinesses(forceRefresh: true);
      return _toModel(created, created.id);
    } on DioException catch (e) {
      final validation = ApiErrorParser.parseValidation(e);
      if (validation != null) throw validation;

      final isOffline =
          e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout;
      if (isOffline) {
        await _cache.queuePendingCreate(request);
        throw const BusinessOfflineException();
      }
      rethrow;
    }
  }

  Future<void> syncPendingCreates() => _syncPendingCreates();

  Future<void> _syncPendingCreates() async {
    final pending = await _cache.readPendingCreates();
    if (pending.isEmpty) return;

    for (final item in pending) {
      await _repository.createBusiness(
        CreateBusinessRequest(
          name: item['name'] as String,
          ownerName: item['owner_name'] as String?,
          phone: item['phone'] as String?,
          email: item['email'] as String?,
          gstin: item['gstin'] as String?,
          businessType: item['business_type'] as String?,
          state: item['state'] as String?,
          currency: item['currency'] as String?,
          address: item['address'] as String?,
        ),
      );
    }
    await _cache.clearPendingCreates();
  }

  Future<void> cacheProfile(AccountProfile profile) =>
      _cache.saveProfile(profile);

  Future<AccountProfile?> readCachedProfile() => _cache.readProfile();

  Future<BusinessProfileModel?> readCachedBusinessProfile() =>
      _cache.readBusinessProfile();

  /// Business list from local storage only — no network calls.
  Future<List<BusinessModel>> readCachedBusinesses() async {
    final selectedId = _cache.readLastOpenedBusinessId();
    return _loadFromCache(selectedId);
  }

  Future<String?> resolveActiveBusinessId() => _resolveBusinessIdForScope();

  Future<String?> _resolveBusinessIdForScope() async {
    final fromCache = _cache.readLastOpenedBusinessId();
    if (fromCache != null && fromCache.isNotEmpty) return fromCache;

    final storage = await _ref.read(storageServiceProvider.future);
    final selected = await storage.readSecure(StorageKeys.selectedBusinessId);
    if (selected != null && selected.isNotEmpty) return selected;

    final auth = _ref.read(authProvider);
    if (auth.session?.businesses.length == 1) {
      return auth.session!.businesses.first.id;
    }

    return null;
  }

  Future<void> seedOfflineDevSession(AuthSession session) async {
    if (!AuthService.isOfflineDevSession(session)) return;
    if (session.businesses.isEmpty) return;

    final businessSummary = session.businesses.first;
    final profile = AuthService.offlineDevBusinessProfile(session);

    await _cache.saveBusinessProfile(profile);
    await rememberLastOpened(businessSummary.id);
    await _cache.saveBusinesses(
      [
        {
          'id': businessSummary.id,
          'name': businessSummary.name,
          'role': businessSummary.role,
          'owner_name': session.user.name,
          'phone': session.user.phone,
        },
      ],
      accountId: session.user.id,
    );
    await _seedOfflineInventoryCatalog(businessSummary.id);
    await _ensureOfflineDefaultGodown(businessSummary.id);
  }

  /// Ensures a default warehouse exists for offline stock adjustments.
  Future<void> _ensureOfflineDefaultGodown(String businessId) async {
    final db = _ref.read(appDatabaseProvider);
    final local = GodownLocalSource(db);
    final existing = await local.countActive(businessId);
    if (existing > 0) return;

    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    await local.upsertFromDto(
      businessId,
      GodownDto(
        id: 'dev-godown-main',
        name: 'Main Warehouse',
        isDefault: true,
        stockItemCount: 0,
        createdAt: nowIso,
        updatedAt: nowIso,
        address: null,
      ),
    );
    BusinessOpenDebugLog.step('offline-dev', 'seeded default godown');
  }

  /// Populates local SQLite from [InventoryCatalog] when the API is unreachable.
  Future<void> _seedOfflineInventoryCatalog(String businessId) async {
    final db = _ref.read(appDatabaseProvider);
    final local = ItemLocalSource(db);
    final existing = await local.countActive(businessId);
    if (existing > 0) return;

    final now = DateTime.now().toUtc().toIso8601String();
    for (final item in InventoryCatalog.items) {
      await local.upsertFromDetailDto(
        businessId,
        ItemDetailDto(
          id: item.id,
          name: item.name,
          itemType: item.type == ItemType.service ? 'service' : 'product',
          hasStockTracking: item.type != ItemType.service,
          baseUnit: item.baseUnitShortName ?? 'Pcs',
          salePrice: (item.salePrice ?? 0).toString(),
          purchasePrice: (item.purchasePrice ?? 0).toString(),
          createdAt: now,
          updatedAt: now,
          shortName: item.shortName,
          alias: item.alias,
          searchKeywords: item.searchKeywords,
          defaultTaxRate: item.defaultTaxRate?.toString(),
          description: item.description,
          categoryId: item.categoryId,
          brandId: item.brandId,
          hsnCode: item.hsnCode,
          barcode: item.barcode,
          mrp: item.mrp?.toString(),
          reorderLevel: item.reorderLevel?.toString(),
          primaryImageUrl: item.primaryImageUrl,
          quantity: item.quantity?.toString(),
          availableForSale: item.availableForSale?.toString(),
          reservedQuantity: item.reservedQuantity?.toString(),
        ),
      );
    }
    BusinessOpenDebugLog.step(
      'offline-dev',
      'seeded ${InventoryCatalog.items.length} catalog items',
    );
  }

  Future<bool> _isOfflineDevSession() async {
    final storage = await _ref.read(storageServiceProvider.future);
    final token = await storage.readSecure(StorageKeys.accessToken);
    return AuthService.isOfflineDevToken(token ?? '');
  }

  Future<void> ensureProfileApiBusinessScope({
    bool forceReselect = false,
  }) async {
    final businessId = await _resolveBusinessIdForScope();
    if (businessId != null &&
        businessId.isNotEmpty &&
        BusinessSelectionRetryGuard.isBlocked(businessId)) {
      BusinessSelectionRetryGuard.logBlockedOnce(
        'ensureProfileApiBusinessScope',
        businessId,
      );
      return;
    }

    final storage = await _ref.read(storageServiceProvider.future);
    final token = await storage.readSecure(StorageKeys.accessToken);

    if (token != null && AuthService.isOfflineDevToken(token)) {
      final businessId = await _resolveBusinessIdForScope();
      if (businessId != null && businessId.isNotEmpty) {
        await rememberLastOpened(businessId);
      }
      return;
    }

    final jwtBusinessId = JwtUtils.businessId(token);
    final jwtRole = JwtUtils.role(token);

    BusinessProfileDebugLog.section('PROFILE API SCOPE CHECK');
    BusinessProfileDebugLog.log(
      'jwt business_id=${jwtBusinessId ?? '(missing)'} role=${jwtRole ?? '(missing)'}',
    );
    BusinessProfileDebugLog.log(
      'authHasBusinessScope=${authHasBusinessScope(_ref.read(authProvider))}',
    );

    if (!forceReselect && jwtBusinessId != null && jwtBusinessId.isNotEmpty) {
      final expectedId = _cache.readLastOpenedBusinessId();
      if (expectedId == null ||
          expectedId.isEmpty ||
          jwtBusinessId == expectedId) {
        return;
      }
      BusinessProfileDebugLog.log(
        'JWT scoped to $jwtBusinessId but expected $expectedId — re-scoping',
      );
    }

    BusinessProfileDebugLog.log(
      'resolved business_id=${businessId ?? '(none)'} forceReselect=$forceReselect',
    );

    if (businessId == null || businessId.isEmpty) {
      throw const BusinessProfileScopeRequired();
    }

    BusinessProfileDebugLog.log(
      'Re-selecting business to scope JWT: $businessId',
    );
    await scopeJwtToBusiness(businessId);
  }

  /// Re-scopes the JWT to [businessId] without touching business list/profile providers.
  Future<void> scopeJwtToBusiness(String businessId) async {
    if (BusinessSelectionRetryGuard.isBlocked(businessId)) {
      return;
    }
    await rememberLastOpened(businessId);
    await _ref.read(authProvider.notifier).selectBusiness(businessId);
  }

  Future<BusinessProfileModel> fetchBusinessProfile({
    bool forceRefresh = false,
  }) async {
    final auth = _ref.read(authProvider);
    if (!authHasBusinessScope(auth)) {
      throw const BusinessProfileScopeRequired();
    }

    final session = auth.session;
    if (session != null && AuthService.isOfflineDevSession(session)) {
      final selectedBusinessId = _cache.readLastOpenedBusinessId();
      if (!forceRefresh) {
        final cached = await _cache.readBusinessProfile();
        if (cached != null &&
            (selectedBusinessId == null || cached.id == selectedBusinessId)) {
          return cached;
        }
      }
      final profile = AuthService.offlineDevBusinessProfile(session);
      await _cache.saveBusinessProfile(profile);
      return profile;
    }

    final selectedBusinessId = _cache.readLastOpenedBusinessId();
    final scopeId = await _resolveBusinessIdForScope();

    if (scopeId != null &&
        scopeId.isNotEmpty &&
        BusinessSelectionRetryGuard.isBlocked(scopeId)) {
      final cached = await _cache.readBusinessProfile();
      if (cached != null &&
          (selectedBusinessId == null || cached.id == selectedBusinessId)) {
        BusinessProfileDebugLog.log(
          'Returning cached business profile (backend unreachable)',
        );
        return cached;
      }
      throw const BusinessServerUnavailable();
    }

    if (!forceRefresh) {
      final cached = await _cache.readBusinessProfile();
      if (cached != null &&
          (selectedBusinessId == null || cached.id == selectedBusinessId)) {
        BusinessProfileDebugLog.log('Returning cached business profile');
        return cached;
      }
    }

    await ensureProfileApiBusinessScope();

    try {
      final remote = await _repository.getBusinessProfile();
      await _cache.saveBusinessProfile(remote);
      return remote;
    } on DioException catch (e) {
      if (NetworkExceptionClassifier.isConnectivityError(e)) {
        final cached = await _cache.readBusinessProfile();
        if (cached != null &&
            (selectedBusinessId == null || cached.id == selectedBusinessId)) {
          BusinessProfileDebugLog.log(
            'Returning cached business profile (connectivity error)',
          );
          return cached;
        }
        throw const BusinessServerUnavailable();
      }

      if (ApiErrorParser.errorCode(e) == 'BUSINESS_NOT_SELECTED' &&
          e.response != null &&
          !BusinessSelectionRetryGuard.isBlocked(scopeId)) {
        await ensureProfileApiBusinessScope(forceReselect: true);
        final remote = await _repository.getBusinessProfile();
        await _cache.saveBusinessProfile(remote);
        return remote;
      }

      final cached = await _cache.readBusinessProfile();
      if (cached != null &&
          (selectedBusinessId == null || cached.id == selectedBusinessId)) {
        return cached;
      }
      rethrow;
    }
  }

  Future<BusinessProfileModel> updateBusinessProfile(
    UpdateBusinessProfileInput input,
  ) async {
    final request = input.toRequest();
    BusinessProfileDebugLog.section('UPDATE PROFILE REQUEST');
    BusinessProfileDebugLog.log('payload: ${request.toJson()}');

    await ensureProfileApiBusinessScope();

    try {
      return await _repository.updateBusinessProfile(request);
    } on DioException catch (e) {
      if (NetworkExceptionClassifier.isConnectivityError(e)) {
        throw const BusinessServerUnavailable();
      }
      if (ApiErrorParser.errorCode(e) == 'BUSINESS_NOT_SELECTED' &&
          e.response != null) {
        final scopeId = await _resolveBusinessIdForScope();
        if (BusinessSelectionRetryGuard.isBlocked(scopeId)) {
          throw const BusinessServerUnavailable();
        }
        BusinessProfileDebugLog.log(
          'BUSINESS_NOT_SELECTED — retrying after re-scope',
        );
        await ensureProfileApiBusinessScope(forceReselect: true);
        return _repository.updateBusinessProfile(request);
      }

      final validation = ApiErrorParser.parseValidation(e);
      if (validation != null) throw validation;
      rethrow;
    }
  }

  Future<void> persistSavedProfile(BusinessProfileModel profile) async {
    await _cache.updateSelectedBusiness(profile);
    await _cache.updateBusinessListEntry(profile);
    _ref
        .read(authProvider.notifier)
        .patchBusinessFromProfile(
          businessId: profile.id,
          name: profile.name,
          gstin: profile.gstin,
        );
  }

  Future<void> rememberLastOpened(String businessId) =>
      _cache.saveLastOpenedBusinessId(businessId);

  Future<void> clearCachedBusinessProfile() => _cache.clearBusinessProfile();

  Future<bool> isJwtScopedToBusiness(String businessId) async {
    if (await _isOfflineDevSession()) {
      final selected = _cache.readLastOpenedBusinessId();
      return selected == businessId;
    }

    final storage = await _ref.read(storageServiceProvider.future);
    final token = await storage.readSecure(StorageKeys.accessToken);
    final jwtBusinessId = JwtUtils.businessId(token);
    final role = JwtUtils.role(token);
    return jwtBusinessId == businessId && role != null && role.isNotEmpty;
  }

  /// Scopes JWT to [businessId] and clears stale profile cache before API calls.
  Future<void> prepareScopeForBusiness(String businessId) async {
    await clearCachedBusinessProfile();
    await scopeJwtToBusiness(businessId);
    if (!await isJwtScopedToBusiness(businessId)) {
      throw const BusinessSelectionFailed(
        'Could not open company for editing. Please try again.',
      );
    }
  }

  BusinessModel _toModel(BusinessDetailDto dto, String? selectedId) {
    return BusinessModel(
      id: dto.id,
      name: dto.name,
      syncStatus: SyncStatus.on,
      isShared: dto.isShared,
      isCurrent: selectedId != null && selectedId == dto.id,
      gstin: dto.gstin,
      ownerName: dto.ownerName,
      phone: dto.phone,
      email: dto.email,
      address: dto.address,
      role: dto.role,
      logoUrl: dto.logoUrl,
    );
  }

  Map<String, dynamic> _businessToJson(BusinessDetailDto dto) => {
    'id': dto.id,
    'name': dto.name,
    'role': dto.role,
    'gstin': dto.gstin,
    'phone': dto.phone,
    'email': dto.email,
    'state_code': dto.stateCode,
    'address': dto.address,
    'owner_name': dto.ownerName,
    'is_shared': dto.isShared,
    'logo_url': dto.logoUrl,
  };

  Future<void> deleteBusiness(String businessId) async {
    await _repository.deleteBusiness(businessId);
    await _cache.removeBusiness(businessId);

    final storage = await _ref.read(storageServiceProvider.future);
    await SessionCacheCleanup(storage).clearBusinessData(businessId);

    final db = _ref.read(appDatabaseProvider);
    await BusinessLocalDataCleanup(db).clearBusiness(businessId);

    final selectedId = _cache.readLastOpenedBusinessId();
    if (selectedId == businessId) {
      await _cache.clearSelectedBusiness();
      await storage.deleteSecure(StorageKeys.selectedBusinessId);
    }
  }

  Future<String?> readActiveBusinessId() async {
    final fromCache = _cache.readLastOpenedBusinessId();
    if (fromCache != null && fromCache.isNotEmpty) return fromCache;

    final storage = await _ref.read(storageServiceProvider.future);
    final selected = await storage.readSecure(StorageKeys.selectedBusinessId);
    if (selected != null && selected.isNotEmpty) return selected;

    final auth = _ref.read(authProvider);
    if (auth.session?.user.role != null) {
      final profile = await _cache.readBusinessProfile();
      return profile?.id;
    }

    return null;
  }
}

class BusinessProfileScopeRequired implements Exception {
  const BusinessProfileScopeRequired();

  @override
  String toString() => 'BusinessProfileScopeRequired';
}

class BusinessSelectionFailed implements Exception {
  const BusinessSelectionFailed([this.message = 'Could not select business']);

  final String message;

  @override
  String toString() => message;
}

bool authHasBusinessScope(AuthState auth) =>
    auth.status == AuthStatus.authenticated && auth.session?.user.role != null;

class BusinessOfflineException implements Exception {
  const BusinessOfflineException();
}

/// Backend is unreachable (connection refused, timeout, etc.).
class BusinessServerUnavailable implements Exception {
  const BusinessServerUnavailable();

  @override
  String toString() =>
      'Server is unavailable. Check your connection and try again.';
}

@Riverpod(keepAlive: true)
class BusinessList extends _$BusinessList {
  @override
  Future<List<BusinessModel>> build() async {
    final service = await ref.watch(businessServiceProvider.future);
    return service.fetchBusinesses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(businessServiceProvider.future);
      return service.fetchBusinesses(forceRefresh: true);
    });
  }

  Future<void> _activateBusiness(String id) async {
    final service = await ref.read(businessServiceProvider.future);
    if (BusinessSelectionRetryGuard.isBlocked(id)) {
      BusinessSelectionRetryGuard.logBlockedOnce('activateBusiness', id);
      await service.rememberLastOpened(id);
      return;
    }

    BusinessOpenDebugLog.step('activate', 'rememberLastOpened $id');
    await service.rememberLastOpened(id);
    BusinessOpenDebugLog.step('activate', 'selectBusiness (JWT refresh)');
    await ref.read(authProvider.notifier).selectBusiness(id);
    _ensureOpenRefMounted('after selectBusiness');
    BusinessOpenDebugLog.step('activate', 'selectBusiness done');
  }

  /// Scopes the session, clears stale caches, reloads providers, and pre-warms
  /// dashboard data before navigating into the app shell.
  Future<void> openBusiness(String id) async {
    BusinessOpenDebugLog.step('openBusiness', 'start id=$id');
    _ensureOpenRefMounted('openBusiness start');
    SyncPauseGate.instance.pause();

    try {
      final service = await ref.read(businessServiceProvider.future);
      _ensureOpenRefMounted('after resolve BusinessService');

      final previousId = await service.readActiveBusinessId();
      final isSwitch =
          previousId != null && previousId.isNotEmpty && previousId != id;
      BusinessOpenDebugLog.step(
        'openBusiness',
        'previousId=${previousId ?? '(none)'} isSwitch=$isSwitch',
      );

      if (isSwitch) {
        BusinessOpenDebugLog.step('openBusiness', 'clear stale profile cache');
        await service.clearCachedBusinessProfile();
        ref.invalidate(posCartProvider);
      }

      await _activateBusiness(id);
      _ensureOpenRefMounted('after activateBusiness');

      BusinessOpenDebugLog.step('openBusiness', 'verify JWT scope');
      if (!await service.isJwtScopedToBusiness(id)) {
        throw const BusinessSelectionFailed(
          'Could not scope session to company. Please try again.',
        );
      }

      BusinessOpenDebugLog.step(
        'openBusiness',
        'invalidate providers (keep BusinessService alive)',
      );
      invalidateAllBusinessScopedProviders(
        ref,
        includeBusinessService: false,
      );
      _ensureOpenRefMounted('after invalidate');

      BusinessOpenDebugLog.step('openBusiness', 'warm providers');
      await warmBusinessScopedProviders(ref, businessId: id);
      BusinessOpenDebugLog.step('openBusiness', 'complete');
    } finally {
      SyncPauseGate.instance.resume();
    }

    await ensureSyncEngineStarted(ref);
  }

  void _ensureOpenRefMounted(String step) {
    if (ref.mounted) return;
    BusinessOpenDebugLog.step(step, 'aborted — BusinessList ref disposed');
    throw const BusinessSelectionFailed(
      'Company switch was interrupted. Please try again.',
    );
  }

  Future<BusinessModel> createBusiness(CreateBusinessRequest request) async {
    final service = await ref.read(businessServiceProvider.future);
    final created = await service.createBusiness(request);
    await _activateBusiness(created.id);
    _ensureOpenRefMounted('createBusiness after activate');

    await ref.read(authProvider.notifier).refreshBusinesses();
    invalidateAllBusinessScopedProviders(
      ref,
      includeBusinessService: false,
    );
    _ensureOpenRefMounted('createBusiness after invalidate');

    await warmBusinessScopedProviders(ref, businessId: created.id);
    await refresh();
    return created;
  }

  void applyProfileUpdate(BusinessProfileModel profile) {
    final businesses = state.asData?.value;
    if (businesses == null) return;

    state = AsyncData(
      businesses
          .map(
            (business) => business.id == profile.id
                ? business.copyWith(
                    name: profile.name,
                    logoUrl: profile.logoUrl,
                  )
                : business,
          )
          .toList(),
    );
  }

  Future<void> deleteBusiness(String id) async {
    _ensureOpenRefMounted('deleteBusiness start');
    final service = await ref.read(businessServiceProvider.future);
    final activeId = await service.readActiveBusinessId();
    final wasActive = activeId == id;

    await service.deleteBusiness(id);
    _ensureOpenRefMounted('deleteBusiness after API');

    if (wasActive) {
      await ref.read(authProvider.notifier).enterBusinessSelection();
      // enterBusinessSelection invalidates businessListProvider — stop here.
      return;
    }

    await ref.read(authProvider.notifier).refreshBusinesses();
    _ensureOpenRefMounted('deleteBusiness after refreshBusinesses');

    _removeBusinessFromState(id);

    invalidateAllBusinessScopedProviders(
      ref,
      includeBusinessService: false,
    );
    await refresh();
  }

  void _removeBusinessFromState(String id) {
    final businesses = state.asData?.value;
    if (businesses == null) return;

    state = AsyncData(
      businesses.where((business) => business.id != id).toList(),
    );
  }

  Future<BusinessProfileModel> fetchProfileForEdit(String businessId) async {
    final service = await ref.read(businessServiceProvider.future);

    await service.prepareScopeForBusiness(businessId);

    final profile = await service.fetchBusinessProfile(forceRefresh: true);
    if (profile.id != businessId) {
      throw const BusinessSelectionFailed(
        'Could not load company details. Please try again.',
      );
    }

    return profile;
  }
}

@riverpod
String loggedInPhone(Ref ref) {
  final auth = ref.watch(authProvider);
  final phone = auth.session?.user.phone ?? auth.phone;
  if (phone.length <= 10) return phone;
  return phone.substring(phone.length - 10);
}

@Riverpod(keepAlive: true)
class BusinessProfile extends _$BusinessProfile {
  @override
  Future<BusinessProfileModel> build() async {
    final authScope = ref.watch(
      authProvider.select(businessProfileAuthScope),
    );
    if (!businessProfileHasScope(authScope)) {
      throw const BusinessProfileScopeRequired();
    }

    final service = await ref.watch(businessServiceProvider.future);
    final businessId = await service.resolveActiveBusinessId();
    if (businessId != null &&
        businessId.isNotEmpty &&
        BusinessSelectionRetryGuard.isBlocked(businessId)) {
      final cached = await service.readCachedBusinessProfile();
      if (cached != null) {
        return cached;
      }

      final cachedBusinesses = await service.readCachedBusinesses();
      for (final business in cachedBusinesses) {
        if (business.id == businessId) {
          return BusinessProfileModel(
            id: business.id,
            name: business.name,
            ownerName: business.ownerName,
            phone: business.phone,
            email: business.email,
            gstin: business.gstin,
            address: business.address,
            logoUrl: business.logoUrl,
          );
        }
      }

      final authBusinesses = ref.read(authProvider).session?.businesses;
      if (authBusinesses != null) {
        for (final business in authBusinesses) {
          if (business.id == businessId) {
            return BusinessProfileModel(
              id: business.id,
              name: business.name,
              gstin: business.gstin,
            );
          }
        }
      }

      throw const BusinessServerUnavailable();
    }

    return service.fetchBusinessProfile();
  }

  Future<BusinessProfileModel> updateProfile(
    UpdateBusinessProfileInput input,
  ) async {
    final service = await ref.read(businessServiceProvider.future);
    final updated = await service.updateBusinessProfile(input);
    await service.persistSavedProfile(updated);
    ref.read(businessListProvider.notifier).applyProfileUpdate(updated);
    state = AsyncData(updated);
    return updated;
  }

  /// Seeds provider state after a business switch without awaiting [.future].
  void replaceWith(BusinessProfileModel profile) {
    state = AsyncData(profile);
  }
}

@riverpod
BusinessProfileModel? currentBusiness(Ref ref) {
  return ref.watch(businessProfileProvider).asData?.value;
}

@riverpod
SidebarBusiness sidebarBusiness(Ref ref) {
  final profile = ref.watch(currentBusinessProvider);
  if (profile != null) {
    return SidebarBusiness(
      id: profile.id,
      name: profile.name,
      seed: profile.id,
      logoUrl: profile.logoUrl,
    );
  }

  return const SidebarBusiness(
    name: 'My Business',
    seed: 'default',
  );
}

class SidebarBusiness {
  const SidebarBusiness({
    required this.name,
    required this.seed,
    this.id,
    this.logoUrl,
  });

  final String? id;
  final String name;
  final String seed;
  final String? logoUrl;
}
