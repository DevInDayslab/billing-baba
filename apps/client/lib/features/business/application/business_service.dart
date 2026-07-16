import 'dart:async';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/utils/jwt_utils.dart';
import 'package:billing_baba/features/auth/models/account_profile.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/data/business_cache.dart';
import 'package:billing_baba/features/business/data/business_repository.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';
import 'package:billing_baba/features/business/utils/business_profile_debug_log.dart';
import 'package:dio/dio.dart';
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
    final accountId = auth.session?.user.id;
    final selectedId = authHasBusinessScope(auth)
        ? _cache.readLastOpenedBusinessId()
        : null;

    if (accountId != null) {
      final cachedAccountId = _cache.readCachedBusinessesAccountId();
      if (cachedAccountId != null &&
          cachedAccountId.isNotEmpty &&
          cachedAccountId != accountId) {
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

  Future<void> ensureProfileApiBusinessScope({
    bool forceReselect = false,
  }) async {
    final storage = await _ref.read(storageServiceProvider.future);
    final token = await storage.readSecure(StorageKeys.accessToken);
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
      return;
    }

    final businessId = await _resolveBusinessIdForScope();
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

    await ensureProfileApiBusinessScope();

    final selectedBusinessId = _cache.readLastOpenedBusinessId();

    if (!forceRefresh) {
      final cached = await _cache.readBusinessProfile();
      if (cached != null &&
          (selectedBusinessId == null || cached.id == selectedBusinessId)) {
        BusinessProfileDebugLog.log('Returning cached business profile');
        return cached;
      }
    }

    try {
      final remote = await _repository.getBusinessProfile();
      await _cache.saveBusinessProfile(remote);
      return remote;
    } on DioException catch (e) {
      if (ApiErrorParser.errorCode(e) == 'BUSINESS_NOT_SELECTED') {
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
      if (ApiErrorParser.errorCode(e) == 'BUSINESS_NOT_SELECTED') {
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
  };

  Future<void> deleteBusiness(String businessId) async {
    await _repository.deleteBusiness(businessId);
    await _cache.removeBusiness(businessId);
    final selectedId = _cache.readLastOpenedBusinessId();
    if (selectedId == businessId) {
      await _cache.clearSelectedBusiness();
    }
  }
}

class BusinessProfileScopeRequired implements Exception {
  const BusinessProfileScopeRequired();
}

bool authHasBusinessScope(AuthState auth) =>
    auth.status == AuthStatus.authenticated && auth.session?.user.role != null;

class BusinessOfflineException implements Exception {
  const BusinessOfflineException();
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
    await service.rememberLastOpened(id);
    await ref.read(authProvider.notifier).selectBusiness(id);
  }

  Future<void> selectBusiness(String id) async {
    await _activateBusiness(id);
    ref
      ..invalidate(businessProfileProvider)
      ..invalidateSelf();
  }

  Future<BusinessModel> createBusiness(CreateBusinessRequest request) async {
    final service = await ref.read(businessServiceProvider.future);
    final created = await service.createBusiness(request);
    await _activateBusiness(created.id);
    await ref.read(authProvider.notifier).refreshBusinesses();
    ref
      ..invalidate(businessProfileProvider)
      ..invalidateSelf();
    return created;
  }

  void applyProfileUpdate(BusinessProfileModel profile) {
    final businesses = state.asData?.value;
    if (businesses == null) return;

    state = AsyncData(
      businesses
          .map(
            (business) => business.id == profile.id
                ? business.copyWith(name: profile.name)
                : business,
          )
          .toList(),
    );
  }

  Future<void> deleteBusiness(String id) async {
    final service = await ref.read(businessServiceProvider.future);
    await service.deleteBusiness(id);
    await ref.read(authProvider.notifier).refreshBusinesses();
    ref
      ..invalidate(businessProfileProvider)
      ..invalidateSelf();
  }

  Future<BusinessProfileModel> fetchProfileForEdit(String businessId) async {
    await _activateBusiness(businessId);
    ref.invalidate(businessProfileProvider);
    final service = await ref.read(businessServiceProvider.future);
    return service.fetchBusinessProfile(forceRefresh: true);
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
    final auth = ref.watch(authProvider);
    if (!authHasBusinessScope(auth)) {
      throw const BusinessProfileScopeRequired();
    }

    final service = await ref.watch(businessServiceProvider.future);
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
  });

  final String? id;
  final String name;
  final String seed;
}
