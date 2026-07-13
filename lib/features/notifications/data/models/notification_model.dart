import 'package:hive_ce/hive.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/app_notification.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 6)
class NotificationModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String body;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  bool? isRead;

  @HiveField(5)
  String? typeString; // stores NotificationType.name

  @HiveField(6)
  String? actionRoute;

  @HiveField(7)
  Map<dynamic, dynamic>? extra;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead,
    this.typeString,
    this.actionRoute,
    this.extra,
  });

  factory NotificationModel.fromEntity(AppNotification n) => NotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        date: n.date,
        isRead: n.isRead,
        typeString: n.type.name,
        actionRoute: n.actionRoute,
        extra: n.extra,
      );

  AppNotification toEntity() => AppNotification(
        id: id,
        title: title,
        body: body,
        date: date,
        isRead: isRead ?? false,
        type: NotificationType.fromString(typeString),
        actionRoute: actionRoute,
        extra: extra != null ? Map<String, dynamic>.from(extra!) : null,
      );
}
