import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/auth/models/account_profile.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/data/business_cache.dart';
import 'package:billing_baba/features/business/data/business_repository.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';
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

  Future<List<BusinessModel>> fetchBusinesses({bool forceRefresh = false}) async {
    final selectedId = _ref.read(authProvider).session?.user.role != null
        ? _cache.readLastOpenedBusinessId()
        : null;

    if (!forceRefresh) {
      final cached = await _loadFromCache(selectedId);
      if (cached.isNotEmpty) {
        _refreshInBackground(selectedId);
        return cached;
      }
    }

    try {
      final remote = await _repository.listBusinesses();
      await _cache.saveBusinesses(
        remote.map(_businessToJson).toList(),
      );
      return remote.map((b) => _toModel(b, selectedId)).toList();
    } on DioException {
      final cached = await _loadFromCache(selectedId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> _refreshInBackground(String? selectedId) async {
    try {
      final remote = await _repository.listBusinesses();
      await _cache.saveBusinesses(
        remote.map(_businessToJson).toList(),
      );
      _ref.invalidate(businessListProvider);
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

      final isOffline = e.response == null ||
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

  Future<void> rememberLastOpened(String businessId) =>
      _cache.saveLastOpenedBusinessId(businessId);

  BusinessModel _toModel(BusinessDetailDto dto, String? selectedId) {
    return BusinessModel(
      id: dto.id,
      name: dto.name,
      syncStatus: SyncStatus.on,
      isShared: dto.isShared,
      isCurrent: selectedId != null && selectedId == dto.id,
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
        'is_shared': dto.isShared,
      };
}

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

  Future<void> selectBusiness(String id) async {
    final service = await ref.read(businessServiceProvider.future);
    await service.rememberLastOpened(id);
    await ref.read(authProvider.notifier).selectBusiness(id);
    ref.invalidateSelf();
  }

  Future<BusinessModel> createBusiness(CreateBusinessRequest request) async {
    final service = await ref.read(businessServiceProvider.future);
    final created = await service.createBusiness(request);
    await ref.read(authProvider.notifier).refreshBusinesses();
    await selectBusiness(created.id);
    ref.invalidateSelf();
    return created;
  }
}

@riverpod
String loggedInPhone(Ref ref) {
  final auth = ref.watch(authProvider);
  final phone = auth.session?.user.phone ?? auth.phone;
  if (phone.length <= 10) return phone;
  return phone.substring(phone.length - 10);
}
