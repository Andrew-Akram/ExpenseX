// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  iconName: json['iconName'] as String,
  colorValue: (json['colorValue'] as num).toInt(),
  isCustom: json['isCustom'] as bool,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 999,
  isHidden: json['isHidden'] as bool? ?? false,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'iconName': instance.iconName,
  'colorValue': instance.colorValue,
  'isCustom': instance.isCustom,
  'displayOrder': instance.displayOrder,
  'isHidden': instance.isHidden,
};
