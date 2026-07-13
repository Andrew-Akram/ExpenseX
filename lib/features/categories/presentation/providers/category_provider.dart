import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/category.dart';

final categoryListProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
  CategoryNotifier.new,
);

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() =>
      ref.read(categoryRepositoryProvider).getCategories();

  Future<void> addCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).addCategory(category);
    ref.invalidateSelf();
  }

  Future<void> updateCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).updateCategory(category);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(id);
    ref.invalidateSelf();
  }
}
