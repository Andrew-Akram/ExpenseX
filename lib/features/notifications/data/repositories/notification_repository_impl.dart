import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_firestore_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationFirestoreDataSource _ds;
  NotificationRepositoryImpl(this._ds);

  @override
  Future<List<AppNotification>> getNotifications() => _ds.getAll();

  @override
  Future<void> addNotification(AppNotification notification) =>
      _ds.save(notification);

  @override
  Future<void> markAsRead(String id) => _ds.markRead(id);

  @override
  Future<void> markAllAsRead() => _ds.markAllRead();

  @override
  Future<void> clearOldNotifications() => _ds.clearOld();

  @override
  Future<int> getUnreadCount() => _ds.getUnreadCount();
}
