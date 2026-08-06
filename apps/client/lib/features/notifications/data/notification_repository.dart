import 'package:billing_baba/features/notifications/data/notification_local_data_source.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._local);

  final NotificationLocalDataSource _local;

  Stream<List<AppNotification>> watchAll(String businessId) {
    return _local.watchAll(businessId);
  }

  Stream<int> watchUnreadCount(String businessId) {
    return _local.watchUnreadCount(businessId);
  }

  Future<List<AppNotification>> getAll(String businessId) {
    return _local.getAll(businessId);
  }

  Future<void> insert(AppNotification notification) {
    return _local.insert(notification);
  }

  Future<void> markRead(String id) {
    return _local.markRead(id);
  }

  Future<void> markAllRead(String businessId) {
    return _local.markAllRead(businessId);
  }

  Future<void> delete(String id) {
    return _local.delete(id);
  }

  Future<void> deleteAll(String businessId) {
    return _local.deleteAll(businessId);
  }
}
