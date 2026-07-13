import 'package:hive_ce/hive.dart';

import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String iconName;

  @HiveField(3)
  late int colorValue;

  @HiveField(4)
  late bool isCustom;

  @HiveField(5)
  int? displayOrder;

  @HiveField(6)
  bool? isHidden;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.isCustom,
    this.displayOrder,
    this.isHidden,
  });

  factory CategoryModel.fromEntity(Category c) => CategoryModel(
        id: c.id,
        name: c.name,
        iconName: c.iconName,
        colorValue: c.colorValue,
        isCustom: c.isCustom,
        displayOrder: c.displayOrder,
        isHidden: c.isHidden,
      );

  Category toEntity() => Category(
        id: id,
        name: name,
        iconName: iconName,
        colorValue: colorValue,
        isCustom: isCustom,
        displayOrder: displayOrder ?? 999,
        isHidden: isHidden ?? false,
      );
}
