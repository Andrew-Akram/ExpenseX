// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type:
          $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.general,
      actionRoute: json['actionRoute'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'date': instance.date.toIso8601String(),
      'isRead': instance.isRead,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'actionRoute': instance.actionRoute,
      'extra': instance.extra,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.budgetExceeded: 'budgetExceeded',
  NotificationType.upcomingBill: 'upcomingBill',
  NotificationType.savingsGoalCompleted: 'savingsGoalCompleted',
  NotificationType.weeklySummary: 'weeklySummary',
  NotificationType.monthlySummary: 'monthlySummary',
  NotificationType.inactiveReminder: 'inactiveReminder',
  NotificationType.general: 'general',
};
