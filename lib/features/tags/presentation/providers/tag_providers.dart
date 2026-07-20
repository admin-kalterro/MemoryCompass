import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_compass/core/di/providers.dart';
import 'package:memory_compass/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:memory_compass/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';
import 'package:memory_compass/features/tags/domain/repositories/tag_repository.dart';
import 'package:memory_compass/features/tags/domain/usecases/create_tag.dart';
import 'package:memory_compass/features/tags/domain/usecases/update_tag.dart';

final tagLocalDataSourceProvider = Provider<TagLocalDataSource>((ref) {
  return TagLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(
    localDataSource: ref.watch(tagLocalDataSourceProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final createTagUseCaseProvider = Provider(
  (ref) => CreateTag(ref.watch(tagRepositoryProvider)),
);

final updateTagUseCaseProvider = Provider(
  (ref) => UpdateTag(ref.watch(tagRepositoryProvider)),
);

/// Live list of every tag, driving tag pickers and the tags management page.
final tagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAllTags();
});
