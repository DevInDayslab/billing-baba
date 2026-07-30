import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:billing_baba/features/business/data/business_cache.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _jwt(Map<String, dynamic> claims) {
  String enc(Object value) {
    final raw = value is String ? value : jsonEncode(value);
    return base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
  }

  return '${enc({'alg': 'none'})}.${enc(claims)}.sig';
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(dio: Dio());

  Object? meError;

  @override
  Future<MeResponse> me(String accessToken) async {
    final error = meError;
    if (error != null) throw error;
    throw StateError('me not configured');
  }
}

class _MemoryStorage extends StorageService {
  _MemoryStorage() : super(preferences: null);

  final Map<String, String> _prefs = {};
  final Map<String, String> _secure = {};

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

  @override
  Future<String?> readSecure(String key) async => _secure[key];

  @override
  Future<void> writeSecure(String key, String value) async {
    _secure[key] = value;
  }

  @override
  Future<void> deleteSecure(String key) async {
    _secure.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryStorage storage;
  late _FakeAuthRepository repository;
  late AuthService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = _MemoryStorage();
    repository = _FakeAuthRepository();
    service = AuthService(repository: repository, storage: storage);
  });

  test(
    'loadStoredSession offline uses JWT user_id/account_id not sub',
    () async {
      final token = _jwt({
        'exp': 2000000000,
        'account_id': 'acct-uuid',
        'user_id': 'user-uuid',
        'phone': '919876543210',
        'role': 'owner',
      });
      await storage.writeSecure(StorageKeys.accessToken, token);
      await storage.writeSecure(StorageKeys.refreshToken, 'refresh');
      await storage.write(StorageKeys.accountPhone, '919876543210');

      repository.meError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        type: DioExceptionType.connectionError,
      );

      final session = await service.loadStoredSession();

      expect(session, isNotNull);
      expect(session!.user.id, 'user-uuid');
      expect(session.user.id, isNot(equals('offline')));
      expect(session.user.phone, '919876543210');
      expect(session.user.role, 'owner');
      expect(session.businesses, isEmpty);
    },
  );

  test(
    'loadStoredSession offline falls back to account_id when unscoped',
    () async {
      final token = _jwt({
        'exp': 2000000000,
        'account_id': 'acct-uuid',
        'phone': '919876543210',
      });
      await storage.writeSecure(StorageKeys.accessToken, token);
      await storage.writeSecure(StorageKeys.refreshToken, 'refresh');

      repository.meError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        type: DioExceptionType.connectionError,
      );

      final session = await service.loadStoredSession();

      expect(session!.user.id, 'acct-uuid');
    },
  );

  test('seedBusinessListCache writes session businesses', () async {
    final token = _jwt({
      'exp': 2000000000,
      'account_id': 'acct-uuid',
    });
    final session = AuthSession(
      accessToken: token,
      refreshToken: 'refresh',
      expiresIn: 0,
      user: const AuthUser(id: 'acct-uuid', phone: '91'),
      businesses: const [
        BusinessSummary(id: 'biz-1', name: 'Acme', role: 'owner'),
      ],
    );

    await service.seedBusinessListCache(session);

    final cache = BusinessCache(storage);
    final cached = await cache.readBusinesses();
    expect(cached, hasLength(1));
    expect(cached.first['id'], 'biz-1');
    expect(cache.readCachedBusinessesAccountId(), 'acct-uuid');
  });
}
