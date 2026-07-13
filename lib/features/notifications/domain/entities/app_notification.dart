import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/app_enums.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    @Default(false) bool isRead,
    @Default(NotificationType.general) NotificationType type,
    String? actionRoute,
    Map<String, dynamic>? extra,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
