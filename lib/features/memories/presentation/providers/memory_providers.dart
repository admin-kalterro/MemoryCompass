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
