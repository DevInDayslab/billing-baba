import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/payments/data/payment_api.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class PaymentRepository {
  PaymentRepository({
    required PaymentApi api,
    required AppDatabase database,
  }) : _api = api,
       _db = database;

  final PaymentApi _api;
  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<GatewayOrderResult> createOrder({
    required Map<String, dynamic> body,
    String? idempotencyKey,
  }) {
    return _api.createOrder(
      body: body,
      idempotencyKey: idempotencyKey ?? _uuid.v4(),
    );
  }

  Future<PaymentVerificationResult> verify({
    required String intentId,
    required RazorpayCheckoutCallback callback,
    String? idempotencyKey,
  }) {
    return _api.verify(
      intentId: intentId,
      paymentId: callback.paymentId,
      orderId: callback.orderId,
      signature: callback.signature,
      idempotencyKey: idempotencyKey ?? _uuid.v4(),
    );
  }

  Future<PaymentVerificationResult> getStatus(String intentId) {
    return _api.getStatus(intentId);
  }

  Future<void> markCheckoutOpen(String intentId) {
    return _api.markCheckoutOpen(intentId);
  }

  Future<void> savePendingSession({
    required String intentId,
    required String razorpayOrderId,
    required String intentPayloadJson,
    String? paymentId,
    String? signature,
  }) async {
    await _db
        .into(_db.gatewayPaymentSessionsLocal)
        .insertOnConflictUpdate(
          GatewayPaymentSessionsLocalCompanion.insert(
            intentId: intentId,
            razorpayOrderId: razorpayOrderId,
            intentPayloadJson: intentPayloadJson,
            status: 'pending_verification',
            paymentId: Value(paymentId),
            signature: Value(signature),
            verifyAttempts: const Value(0),
            lastRetryAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> clearSession(String intentId) async {
    await (_db.delete(
      _db.gatewayPaymentSessionsLocal,
    )..where((t) => t.intentId.equals(intentId))).go();
  }

  Future<List<GatewayPaymentSessionsLocalData>> listPendingSessions() {
    return (_db.select(
      _db.gatewayPaymentSessionsLocal,
    )..where((t) => t.status.equals('pending_verification'))).get();
  }

  Future<void> incrementRetry(String intentId) async {
    final row = await (_db.select(
      _db.gatewayPaymentSessionsLocal,
    )..where((t) => t.intentId.equals(intentId))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(
      _db.gatewayPaymentSessionsLocal,
    )..where((t) => t.intentId.equals(intentId))).write(
      GatewayPaymentSessionsLocalCompanion(
        verifyAttempts: Value(row.verifyAttempts + 1),
        lastRetryAt: Value(DateTime.now()),
      ),
    );
  }
}
