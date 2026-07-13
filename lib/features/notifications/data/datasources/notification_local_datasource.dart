import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';
import '../../domain/entities/app_notification.dart';
import '../models/notification_model.dart';

class NotificationLocalDataSource {
  static String get _boxName => 'notifications_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<NotificationModel> get _box => Hive.box<NotificationModel>(_boxName);

  List<AppNotification> getAll() {
    final list = _box.values.map((m) => m.toEntity()).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> save(AppNotification notification) async {
    await _box.put(notification.id, NotificationModel.fromEntity(notification));
  }

  Future<void> markRead(String id) async {
    final m = _box.get(id);
    if (m != null) {
      m.isRead = true;
      await m.save();
    }
  }

  Future<void> markAllRead() async {
    for (final m in _box.values) {
      if (m.isRead == false || m.isRead == null) {
        m.isRead = true;
        await m.save();
      }
    }
  }

  Future<void> clearOld() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final toDelete = <dynamic>[];
    for (final entry in _box.toMap().entries) {
      if (entry.value.date.isBefore(cutoff)) {
        toDelete.add(entry.key);
      }
    }
    await _box.deleteAll(toDelete);
  }

  int getUnreadCount() {
    return _box.values.where((m) => m.isRead == false || m.isRead == null).length;
  }
}
