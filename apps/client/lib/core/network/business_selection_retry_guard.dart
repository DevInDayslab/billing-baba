import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:flutter/foundation.dart';

/// Prevents repeated [selectBusiness] calls when the backend is unreachable.
abstract final class BusinessSelectionRetryGuard {
  static const _cooldown = Duration(seconds: 60);
  static const _maxRetriesPerBusiness = 1;

  static String? _lastFailedBusinessId;
  static DateTime? _lastFailureAt;
  static int _retryCount = 0;
  static String? _lastFailureReason;
  static String? _skipLoggedForBusinessId;

  /// True when a recent connectivity failure blocks business-selection API calls.
  ///
  /// When [businessId] is omitted, returns whether any business is blocked.
  static bool isBlocked([String? businessId]) {
    final failedId = _lastFailedBusinessId;
    if (failedId == null || failedId.isEmpty) return false;
    if (businessId != null && businessId.isNotEmpty && failedId != businessId) {
      return false;
    }
    if (_retryCount >= _maxRetriesPerBusiness) return true;
    final failedAt = _lastFailureAt;
    return failedAt != null && DateTime.now().difference(failedAt) < _cooldown;
  }

  /// @deprecated Prefer [isBlocked]; kept for call sites being migrated.
  static bool shouldSkip(String businessId) => isBlocked(businessId);

  static int get retryCount => _retryCount;
  static String? get lastFailureReason => _lastFailureReason;

  static void recordConnectivityFailure(String businessId, Object error) {
    if (!NetworkExceptionClassifier.isConnectivityError(error)) return;

    final isSameBusiness = _lastFailedBusinessId == businessId;
    _lastFailedBusinessId = businessId;
    _lastFailureAt = DateTime.now();
    _retryCount = isSameBusiness ? _retryCount + 1 : 1;
    _lastFailureReason = NetworkExceptionClassifier.classify(error).reason;
    _skipLoggedForBusinessId = null;

    debugPrint(
      '[BUSINESS_SELECT] connectivity failure businessId=$businessId '
      'retryCount=$_retryCount reason=$_lastFailureReason',
    );
  }

  static void recordSuccess(String businessId) {
    if (_lastFailedBusinessId == businessId) {
      _reset();
    }
  }

  static void reset() => _reset();

  /// Logs once per blocked business when a caller would have retried.
  static void logBlockedOnce(String caller, String businessId) {
    if (!isBlocked(businessId)) return;
    if (_skipLoggedForBusinessId == businessId) return;
    _skipLoggedForBusinessId = businessId;
    debugPrint(
      '[BUSINESS_SELECT] $caller blocked businessId=$businessId '
      'retryCount=$_retryCount reason=$_lastFailureReason',
    );
  }

  static void _reset() {
    _lastFailedBusinessId = null;
    _lastFailureAt = null;
    _retryCount = 0;
    _lastFailureReason = null;
    _skipLoggedForBusinessId = null;
  }
}
