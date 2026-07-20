import 'package:memory_compass/core/database/app_database.dart';

abstract class TagLocalDataSource {
  Stream<List<TagRow>> watchAll();
  Future<List<TagRow>> getAllOnce();
  Future<void> insert(TagsCompanion tag);
}

class TagLocalDataSourceImpl implements TagLocalDataSource {
  TagLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TagRow>> watchAll() => _database.watchAllTags();

  @override
  Future<List<TagRow>> getAllOnce() => _database.allTagsOnce();

  @override
  Future<void> insert(TagsCompanion tag) => _database.insertTag(tag);
}
