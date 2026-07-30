import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/data/business_cache.dart';
import 'package:billing_baba/features/business/data/business_repository.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

String _jwt(Map<String, dynamic> claims) {
  String enc(Object value) {
    final raw = value is String ? value : jsonEncode(value);
    return base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
  }

  return '${enc({'alg': 'none'})}.${enc(claims)}.sig';
}

class _MemoryStorage extends StorageService {
  _MemoryStorage() : super(preferences: null);

  final Map<String, String> _prefs = {};

  @override
  Future<void> init() async {}

  @override
  String? read(String key) => _prefs[key];

  @override
  Future<void> write(String key, String value) async {
    _prefs[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _prefs.remove(key);
  }
}

class _FakeBusinessRepository extends BusinessRepository {
  _FakeBusinessRepository() : super(Dio());

  int listCalls = 0;

  @override
  Future<List<BusinessDetailDto>> listBusinesses() async {
    listCalls++;
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/businesses'),
      type: DioExceptionType.connectionError,
      message: 'Connection refused',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'fetchBusinesses returns SharedPreferences cache offline without wiping',
    () async {
      final storage = _MemoryStorage();
      final cache = BusinessCache(storage);
      final repo = _FakeBusinessRepository();

      // Historical cache keyed by membership user id (pre-fix keying).
      await cache.saveBusinesses(
        [
          {
            'id': 'biz-1',
            'name': 'Cached Co',
            'role': 'owner',
          },
        ],
        accountId: 'user-uuid',
      );

      final token = _jwt({
        'exp': 2000000000,
        'account_id': 'acct-uuid',
        'user_id': 'user-uuid',
        'role': 'owner',
      });

      final session = AuthSession(
        accessToken: token,
        refreshToken: 'refresh',
        expiresIn: 0,
        user: const AuthUser(
          id: 'user-uuid',
          phone: '919999999999',
          role: 'owner',
        ),
        businesses: const [],
      );

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(
            AuthState(
              status: AuthStatus.needsBusinessSelection,
              session: session,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final serviceProvider = Provider<BusinessService>(
        (ref) => BusinessService(
          repository: repo,
          cache: cache,
          ref: ref,
        ),
      );

      final result = await container.read(serviceProvider).fetchBusinesses();

      expect(result, hasLength(1));
      expect(result.first.id, 'biz-1');
      expect(result.first.name, 'Cached Co');
      // Background refresh may attempt the API once; it must not wipe cache.
      await Future<void>.delayed(Duration.zero);
      expect(storage.read(StorageKeys.cachedBusinesses), isNot(equals('[]')));
      expect(cache.readCachedBusinessesAccountId(), 'user-uuid');
      expect(await cache.readBusinesses(), hasLength(1));
    },
  );

  test(
    'fetchBusinesses does not wipe cache when session id was offline fallback',
    () async {
      final storage = _MemoryStorage();
      final cache = BusinessCache(storage);
      final repo = _FakeBusinessRepository();

      await cache.saveBusinesses(
        [
          {
            'id': 'biz-1',
            'name': 'Cached Co',
            'role': 'owner',
          },
        ],
        accountId: 'acct-uuid',
      );

      // Token still has real account_id (post-fix offline restore).
      final token = _jwt({
        'exp': 2000000000,
        'account_id': 'acct-uuid',
      });

      final session = AuthSession(
        accessToken: token,
        refreshToken: 'refresh',
        expiresIn: 0,
        user: const AuthUser(id: 'acct-uuid', phone: '91'),
        businesses: const [],
      );

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(
            AuthState(
              status: AuthStatus.needsBusinessSelection,
              session: session,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final serviceProvider = Provider<BusinessService>(
        (ref) => BusinessService(
          repository: repo,
          cache: cache,
          ref: ref,
        ),
      );

      final result = await container.read(serviceProvider).fetchBusinesses();

      expect(result, hasLength(1));
      await Future<void>.delayed(Duration.zero);
      expect(await cache.readBusinesses(), hasLength(1));
      expect(cache.readCachedBusinessesAccountId(), 'acct-uuid');
    },
  );
}
