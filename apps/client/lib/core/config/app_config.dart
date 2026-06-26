/// Environment-specific application configuration.
abstract final class AppConfig {
  static const appName = 'Billing Baba';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // TODO(team): Add feature flags and environment detection.
}
