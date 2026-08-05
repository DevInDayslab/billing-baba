import 'package:drift/drift.dart';

/// Local pending Razorpay verification sessions for crash/offline recovery.
class GatewayPaymentSessionsLocal extends Table {
  TextColumn get intentId => text()();
  TextColumn get razorpayOrderId => text()();
  TextColumn get paymentId => text().nullable()();
  TextColumn get signature => text().nullable()();
  TextColumn get status => text()();
  TextColumn get intentPayloadJson => text()();
  IntColumn get verifyAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastRetryAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {intentId};
}
