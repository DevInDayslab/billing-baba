import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/auth/models/auth_session.dart';
import 'package:billing_baba/features/auth/models/auth_user.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/repositories/auth_repository.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({
    required this.healthResult,
    this.devLoginSession,
  }) : super(dio: Dio(BaseOptions(baseUrl: 'http://test')));

  final bool healthResult;
  final AuthSession? devLoginSession;
  int devLoginCalls = 0;

  @override
  Future<bool> checkHealth() async => healthResult;

  @override
  Future<AuthSession> devLogin() async {
    devLoginCalls++;
    final session = devLoginSession;
    if (session == null) {
      throw StateError('devLogin not configured');
    }
    return session;
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

AuthSession _apiDevSession() {
  return const AuthSession(
    accessToken: 'real-api-access-token',
    refreshToken: 'real-api-refresh-token',
    expiresIn: 900,
    user: AuthUser(
      id: 'api-user',
      phone: '919999999999',
      name: 'Rahul Sharma',
      role: 'owner',
    ),
    businesses: [
      BusinessSummary(
        id: 'api-business',
        name: 'Sharma Enterprises',
        role: 'owner',
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(envString: 'API_BASE_URL=http://test\n');
  });

  late _MemoryStorage storage;
  late _FakeAuthRepository repository;
  late AuthService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = _MemoryStorage();
    repository = _FakeAuthRepository(
      healthResult: true,
      devLoginSession: _apiDevSession(),
    );
    service = AuthService(repository: repository, storage: storage);
  });

  test(
    'upgradeOfflineDevSessionIfApiAvailable replaces fake credentials',
    () async {
      await storage.writeSecure(
        StorageKeys.accessToken,
        AuthService.devAccessToken,
      );
      await storage.writeSecure(
        StorageKeys.refreshToken,
        AuthService.devRefreshToken,
      );

      final upgraded = await service.upgradeOfflineDevSessionIfApiAvailable();

      expect(upgraded, isNotNull);
      expect(upgraded!.accessToken, 'real-api-access-token');
      expect(repository.devLoginCalls, 1);
      expect(
        await storage.readSecure(StorageKeys.accessToken),
        'real-api-access-token',
      );
    },
  );

  test(
    'loadStoredSession upgrades offline dev session when API is healthy',
    () async {
      await storage.writeSecure(
        StorageKeys.accessToken,
        AuthService.devAccessToken,
      );
      await storage.writeSecure(
        StorageKeys.refreshToken,
        AuthService.devRefreshToken,
      );

      final session = await service.loadStoredSession();

      expect(session, isNotNull);
      expect(session!.accessToken, 'real-api-access-token');
      expect(session.user.name, 'Rahul Sharma');
      expect(repository.devLoginCalls, 1);
    },
  );

  test(
    'loadStoredSession keeps offline dev session when API is unreachable',
    () async {
      repository = _FakeAuthRepository(healthResult: false);
      service = AuthService(repository: repository, storage: storage);

      await storage.writeSecure(
        StorageKeys.accessToken,
        AuthService.devAccessToken,
      );
      await storage.writeSecure(
        StorageKeys.refreshToken,
        AuthService.devRefreshToken,
      );

      final session = await service.loadStoredSession();

      expect(session, isNotNull);
      expect(session!.accessToken, AuthService.devAccessToken);
      expect(session.user.name, 'Developer');
      expect(repository.devLoginCalls, 0);
    },
  );
}
