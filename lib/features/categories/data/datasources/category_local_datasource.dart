import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/category_constants.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  static String get _boxName => 'categories_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<CategoryModel> get _box => Hive.box<CategoryModel>(_boxName);

  List<Category> getAll() =>
      _box.values.map((m) => m.toEntity()).toList();

  Category? getById(String id) => _box.get(id)?.toEntity();

  Future<void> save(Category category) async {
    await _box.put(category.id, CategoryModel.fromEntity(category));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Seeds the 9 built-in categories on first launch (box empty).
  static Future<void> seedDefaultCategoriesForUser(String uid) async {
    final box = Hive.box<CategoryModel>('categories_$uid');
    if (box.isNotEmpty) return;

    for (final data in CategoryConstants.defaultCategories) {
      final model = CategoryModel(
        id: data['id'] as String,
        name: data['name'] as String,
        iconName: data['iconName'] as String,
        colorValue: (data['colorValue'] as dynamic).value as int,
        isCustom: data['isCustom'] as bool,
      );
      await box.put(model.id, model);
    }
  }
}
