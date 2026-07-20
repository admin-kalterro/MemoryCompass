import 'package:drift/drift.dart' show Value;
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:memory_compass/core/database/app_database.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:memory_compass/features/tags/data/models/tag_mapper.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';
import 'package:memory_compass/features/tags/domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl({
    required TagLocalDataSource localDataSource,
    required Uuid uuid,
  }) : _localDataSource = localDataSource,
       _uuid = uuid;

  final TagLocalDataSource _localDataSource;
  final Uuid _uuid;

  @override
  Stream<List<Tag>> watchAllTags() => _localDataSource.watchAll().map(
    (rows) => rows.map((row) => row.toEntity()).toList(),
  );

  @override
  Future<Either<Failure, List<Tag>>> getAllTagsOnce() async {
    try {
      final rows = await _localDataSource.getAllOnce();
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e) {
      return Left(Failure.storage('Failed to load tags: $e'));
    }
  }

  @override
  Future<Either<Failure, Tag>> createTag({
    required String name,
    required int color,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(Failure.validation('Tag name cannot be empty.'));
    }
    try {
      final existing = await _localDataSource.getAllOnce();
      final isDuplicate = existing.any(
        (row) => row.name.toLowerCase() == trimmed.toLowerCase(),
      );
      if (isDuplicate) {
        return const Left(Failure.validation('That tag already exists.'));
      }

      final now = DateTime.now().toUtc();
      final tag = Tag(
        id: _uuid.v4(),
        name: trimmed,
        color: color,
        createdAt: now,
        updatedAt: now,
      );
      await _localDataSource.insert(_toCompanion(tag));
      return Right(tag);
    } catch (e) {
      return Left(Failure.storage('Failed to create tag: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTag({
    required String id,
    required String name,
    required int color,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(Failure.validation('Tag name cannot be empty.'));
    }
    try {
      final existing = await _localDataSource.getAllOnce();
      TagRow? current;
      for (final row in existing) {
        if (row.id == id) current = row;
      }
      if (current == null) {
        return Left(Failure.notFound('Tag $id not found'));
      }
      final isDuplicate = existing.any(
        (row) =>
            row.id != id && row.name.toLowerCase() == trimmed.toLowerCase(),
      );
      if (isDuplicate) {
        return const Left(Failure.validation('That tag already exists.'));
      }

      await _localDataSource.insert(
        _toCompanion(
          Tag(
            id: id,
            name: trimmed,
            color: color,
            createdAt: current.createdAt,
            updatedAt: DateTime.now().toUtc(),
          ),
        ),
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unexpected('Failed to update tag: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertSyncedTag(Tag tag) async {
    try {
      await _localDataSource.insert(_toCompanion(tag));
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unexpected('Failed to save synced tag: $e'));
    }
  }

  TagsCompanion _toCompanion(Tag tag) => TagsCompanion(
    id: Value(tag.id),
    name: Value(tag.name),
    color: Value(tag.color),
    createdAt: Value(tag.createdAt),
    updatedAt: Value(tag.updatedAt),
  );
}
