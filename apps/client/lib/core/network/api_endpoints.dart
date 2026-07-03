/// API endpoint path constants.
abstract final class ApiEndpoints {
  static const auth = '/api/v1/auth';
  static const businesses = '/api/v1/businesses';
  static const businessProfile = '/api/v1/business/profile';
  static const parties = '/api/v1/parties';
  static String party(String id) => '/api/v1/parties/$id';
  static const sync = '/api/v1/sync';
  static const health = '/api/v1/health';
}
