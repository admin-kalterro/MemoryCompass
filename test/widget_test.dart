import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/utils/exif_extractor.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';
import 'package:memory_compass/features/memories/presentation/pages/map_page.dart';
import 'package:memory_compass/features/memories/presentation/providers/memory_providers.dart';

/// A repository double so the widget test never touches Drift/sqlite or
/// platform channels - it only exercises the presentation layer.
class _FakeMemoryRepository implements MemoryRepository {
  @override
  Stream<List<MemoryPin>> watchAllMemoryPins() => Stream.value(const []);

  @override
  Future<Either<Failure, List<MemoryPin>>> getAllMemoryPinsOnce() async =>
      const Right([]);

  @override
  Future<Either<Failure, ExtractedPhotoMetadata>> readPhotoMetadata(
    String imagePath,
  ) async => const Right(ExtractedPhotoMetadata());

  @override
  Future<Either<Failure, MemoryPin>> addMemoryPin({
    required String sourceImagePath,
    required double latitude,
    required double longitude,
    DateTime? takenAt,
    String? title,
    String? note,
    List<String> tagIds = const [],
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> updateMemoryPinLocation({
    required String id,
    required double latitude,
    required double longitude,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> updateMemoryPinDetails({
    required String id,
    String? title,
    String? note,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteMemoryPin(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> savePhotoBytes({
    required List<int> bytes,
    required String pinId,
    required String extension,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> markSynced({
    required String id,
    required String driveFileId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> upsertSyncedPin(MemoryPin pin) async =>
      throw UnimplementedError();
}

void main() {
  testWidgets('MapPage shows the app title and an add-memory action', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryRepositoryProvider.overrideWithValue(_FakeMemoryRepository()),
        ],
        child: const MaterialApp(home: MapPage()),
      ),
    );
    await tester.pump();

    expect(find.text('MemoryCompass'), findsOneWidget);
    expect(find.text('Add memory'), findsOneWidget);
  });
}
