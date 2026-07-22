import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';
import 'package:memory_compass/features/memories/presentation/providers/memory_providers.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';
import 'package:memory_compass/features/tags/domain/repositories/tag_repository.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';

class MockMemoryRepository extends Mock implements MemoryRepository {}

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  final now = DateTime.utc(2026, 7, 21);

  final scenicPin = MemoryPin(
    id: 'pin-1',
    photoPath: '/app/memories/pin-1.jpg',
    latitude: 51.5,
    longitude: -0.12,
    createdAt: now,
    updatedAt: now,
    title: 'Sunset at the pier',
    note: 'Cold evening, perfect light',
    tagIds: const ['tag-nature'],
  );

  final cityPin = MemoryPin(
    id: 'pin-2',
    photoPath: '/app/memories/pin-2.jpg',
    latitude: 40.7,
    longitude: -74.0,
    createdAt: now,
    updatedAt: now,
    title: 'Downtown food tour',
    note: 'Tried the new ramen place with friends',
    tagIds: const ['tag-food'],
  );

  final natureTag = Tag(
    id: 'tag-nature',
    name: 'Nature',
    color: 0xFF00FF00,
    createdAt: now,
    updatedAt: now,
  );

  final foodTag = Tag(
    id: 'tag-food',
    name: 'Food',
    color: 0xFFFF0000,
    createdAt: now,
    updatedAt: now,
  );

  late MockMemoryRepository memoryRepository;
  late MockTagRepository tagRepository;
  late ProviderContainer container;

  setUp(() {
    memoryRepository = MockMemoryRepository();
    tagRepository = MockTagRepository();
    when(
      () => memoryRepository.watchAllMemoryPins(),
    ).thenAnswer((_) => Stream.value([scenicPin, cityPin]));
    when(
      () => tagRepository.watchAllTags(),
    ).thenAnswer((_) => Stream.value([natureTag, foodTag]));

    container = ProviderContainer(
      overrides: [
        memoryRepositoryProvider.overrideWithValue(memoryRepository),
        tagRepositoryProvider.overrideWithValue(tagRepository),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpStreams() async {
    // Let the watchAllMemoryPins/watchAllTags streams emit their first value.
    await Future<void>.delayed(Duration.zero);
  }

  test('returns every pin when the query is blank', () async {
    container.listen(filteredMemoryPinsProvider, (_, _) {});
    await pumpStreams();

    final result = container.read(filteredMemoryPinsProvider);
    expect(result.value, [scenicPin, cityPin]);
  });

  test('matches on title, case-insensitively', () async {
    container.listen(filteredMemoryPinsProvider, (_, _) {});
    await pumpStreams();

    container.read(memorySearchQueryProvider.notifier).state = 'SUNSET';

    final result = container.read(filteredMemoryPinsProvider);
    expect(result.value, [scenicPin]);
  });

  test('matches on note text', () async {
    container.listen(filteredMemoryPinsProvider, (_, _) {});
    await pumpStreams();

    container.read(memorySearchQueryProvider.notifier).state = 'ramen';

    final result = container.read(filteredMemoryPinsProvider);
    expect(result.value, [cityPin]);
  });

  test('matches on tag name', () async {
    container.listen(filteredMemoryPinsProvider, (_, _) {});
    await pumpStreams();

    container.read(memorySearchQueryProvider.notifier).state = 'nature';
    await pumpStreams();

    final result = container.read(filteredMemoryPinsProvider);
    expect(result.value, [scenicPin]);
  });

  test('returns an empty list when nothing matches', () async {
    container.listen(filteredMemoryPinsProvider, (_, _) {});
    await pumpStreams();

    container.read(memorySearchQueryProvider.notifier).state = 'volcano';
    await pumpStreams();

    final result = container.read(filteredMemoryPinsProvider);
    expect(result.value, isEmpty);
  });
}
