import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_firestore_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryFirestoreDataSource _ds;
  CategoryRepositoryImpl(this._ds);

  @override
  Future<List<Category>> getCategories() => _ds.getAll();

  @override
  Future<Category?> getCategoryById(String id) => _ds.getById(id);

  @override
  Future<void> addCategory(Category category) => _ds.save(category);

  @override
  Future<void> updateCategory(Category category) => _ds.save(category);

  @override
  Future<void> deleteCategory(String id) => _ds.delete(id);
}
