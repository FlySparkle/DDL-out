import '../database/app_database.dart';
import 'category_repository.dart';

final class DriftCategoryRepository implements CategoryRepository {
  const DriftCategoryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<int> create(String name, int colorArgb) =>
      _database.createCategory(name, colorArgb);

  @override
  Future<void> update(Category category, String name, int colorArgb) =>
      _database.updateCategory(category, name, colorArgb);

  @override
  Future<void> reorder(List<int> categoryIds) =>
      _database.reorderCategories(categoryIds);

  @override
  Future<void> delete(int id) => _database.deleteCategory(id);

  @override
  Future<void> clear() => _database.clearCategories();
}
