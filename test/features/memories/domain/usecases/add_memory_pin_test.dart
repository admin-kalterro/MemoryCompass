import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';
import 'package:memory_compass/features/memories/domain/usecases/add_memory_pin.dart';

class MockMemoryRepository extends Mock implements MemoryRepository {}

void main() {
  late MockMemoryRepository repository;
  late AddMemoryPin usecase;

  setUp(() {
    repository = MockMemoryRepository();
    usecase = AddMemoryPin(repository);
  });

  final pin = MemoryPin(
    id: 'pin-1',
    photoPath: '/app/memories/pin-1.jpg',
    latitude: 51.5,
    longitude: -0.12,
    createdAt: DateTime.utc(2024, 6, 21),
    updatedAt: DateTime.utc(2024, 6, 21),
  );

  test(
    'passes params through to the repository and returns its result',
    () async {
      when(
        () => repository.addMemoryPin(
          sourceImagePath: any(named: 'sourceImagePath'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          takenAt: any(named: 'takenAt'),
          title: any(named: 'title'),
          note: any(named: 'note'),
          tagIds: any(named: 'tagIds'),
        ),
      ).thenAnswer((_) async => Right(pin));

      final result = await usecase(
        const AddMemoryPinParams(
          sourceImagePath: '/tmp/source.jpg',
          latitude: 51.5,
          longitude: -0.12,
          title: 'Trip',
        ),
      );

      expect(result, Right(pin));
      verify(
        () => repository.addMemoryPin(
          sourceImagePath: '/tmp/source.jpg',
          latitude: 51.5,
          longitude: -0.12,
          takenAt: null,
          title: 'Trip',
          note: null,
          tagIds: const [],
        ),
      ).called(1);
    },
  );

  test('surfaces a failure from the repository unchanged', () async {
    const failure = Failure.storage('disk full');
    when(
      () => repository.addMemoryPin(
        sourceImagePath: any(named: 'sourceImagePath'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        takenAt: any(named: 'takenAt'),
        title: any(named: 'title'),
        note: any(named: 'note'),
        tagIds: any(named: 'tagIds'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(
      const AddMemoryPinParams(
        sourceImagePath: '/tmp/source.jpg',
        latitude: 0,
        longitude: 0,
      ),
    );

    expect(result, const Left(failure));
  });
}
