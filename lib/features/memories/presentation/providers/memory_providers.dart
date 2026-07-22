import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_compass/core/di/providers.dart';
import 'package:memory_compass/features/memories/data/datasources/memory_local_datasource.dart';
import 'package:memory_compass/features/memories/data/repositories/memory_repository_impl.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';
import 'package:memory_compass/features/memories/domain/usecases/add_memory_pin.dart';
import 'package:memory_compass/features/memories/domain/usecases/delete_memory_pin.dart';
import 'package:memory_compass/features/memories/domain/usecases/extract_photo_location.dart';
import 'package:memory_compass/features/memories/domain/usecases/update_memory_pin_details.dart';
import 'package:memory_compass/features/memories/domain/usecases/update_memory_pin_location.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';

final memoryLocalDataSourceProvider = Provider<MemoryLocalDataSource>((ref) {
  return MemoryLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepositoryImpl(
    localDataSource: ref.watch(memoryLocalDataSourceProvider),
    exifExtractor: ref.watch(exifExtractorProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final addMemoryPinUseCaseProvider = Provider(
  (ref) => AddMemoryPin(ref.watch(memoryRepositoryProvider)),
);

final updateMemoryPinLocationUseCaseProvider = Provider(
  (ref) => UpdateMemoryPinLocation(ref.watch(memoryRepositoryProvider)),
);

final updateMemoryPinDetailsUseCaseProvider = Provider(
  (ref) => UpdateMemoryPinDetails(ref.watch(memoryRepositoryProvider)),
);

final deleteMemoryPinUseCaseProvider = Provider(
  (ref) => DeleteMemoryPin(ref.watch(memoryRepositoryProvider)),
);

final extractPhotoLocationUseCaseProvider = Provider(
  (ref) => ExtractPhotoLocation(ref.watch(memoryRepositoryProvider)),
);

/// Live list of every pin, driving the map markers.
final memoryPinsProvider = StreamProvider<List<MemoryPin>>((ref) {
  return ref.watch(memoryRepositoryProvider).watchAllMemoryPins();
});

/// Free-text search entered in the map's search bar.
final memorySearchQueryProvider = StateProvider<String>((ref) => '');

/// [memoryPinsProvider] narrowed to pins whose title, note, or tag names
/// match [memorySearchQueryProvider]. Falls back to the full pin list once
/// the query is blank.
final filteredMemoryPinsProvider = Provider<AsyncValue<List<MemoryPin>>>((
  ref,
) {
  final pinsAsync = ref.watch(memoryPinsProvider);
  final query = ref.watch(memorySearchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) return pinsAsync;

  final tagNamesById = {
    for (final tag in ref.watch(tagsProvider).valueOrNull ?? const [])
      tag.id: tag.name.toLowerCase(),
  };

  return pinsAsync.whenData(
    (pins) => pins.where((pin) {
      if ((pin.title ?? '').toLowerCase().contains(query)) return true;
      if ((pin.note ?? '').toLowerCase().contains(query)) return true;
      return pin.tagIds.any(
        (id) => tagNamesById[id]?.contains(query) ?? false,
      );
    }).toList(),
  );
});
