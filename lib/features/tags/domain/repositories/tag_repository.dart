import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';

abstract class TagRepository {
  /// Live view of every tag, used to drive tag pickers across the app.
  Stream<List<Tag>> watchAllTags();

  Future<Either<Failure, List<Tag>>> getAllTagsOnce();

  /// Creates a new tag. Fails if [name] is blank or a tag with the same
  /// name (case-insensitive) already exists.
  Future<Either<Failure, Tag>> createTag({
    required String name,
    required int color,
  });

  /// Renames/recolors an existing tag. Fails if [name] is blank or another
  /// tag already has that name (case-insensitive).
  Future<Either<Failure, Unit>> updateTag({
    required String id,
    required String name,
    required int color,
  });

  /// Inserts or overwrites a tag with data reconciled from Drive.
  Future<Either<Failure, Unit>> upsertSyncedTag(Tag tag);
}
