import '../database/app_database.dart';

abstract interface class CategoryRepository {
  Future<int> create(String name, int colorArgb);
  Future<void> update(Category category, String name, int colorArgb);
  Future<void> reorder(List<int> categoryIds);
  Future<void> delete(int id);
  Future<void> clear();
}
