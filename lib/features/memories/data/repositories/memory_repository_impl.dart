import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:memory_compass/core/error/exceptions.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/utils/exif_extractor.dart';
import 'package:memory_compass/features/memories/data/datasources/memory_local_datasource.dart';
import 'package:memory_compass/features/memories/data/models/memory_pin_mapper.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  MemoryRepositoryImpl({
    required MemoryLocalDataSource localDataSource,
    required ExifExtractor exifExtractor,
    required Uuid uuid,
  }) : _localDataSource = localDataSource,
       _exifExtractor = exifExtractor,
       _uuid = uuid;

  final MemoryLocalDataSource _localDataSource;
  final ExifExtractor _exifExtractor;
  final Uuid _uuid;

  @override
  Stream<List<MemoryPin>> watchAllMemoryPins() => _localDataSource
      .watchAll()
      .map((rows) => rows.map((row) => row.toEntity()).toList());

  @override
  Future<Either<Failure, List<MemoryPin>>> getAllMemoryPinsOnce() async {
    try {
      final rows = await _localDataSource.getAllOnce();
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e) {
      return Left(Failure.storage('Failed to load memories: $e'));
    }
  }

  @override
  Future<Either<Failure, ExtractedPhotoMetadata>> readPhotoMetadata(
    String imagePath,
  ) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final metadata = await _exifExtractor.extractFromBytes(bytes);
      return Right(metadata);
    } catch (e) {
      return Left(Failure.storage('Failed to read photo metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, MemoryPin>> addMemoryPin({
    required String sourceImagePath,
    required double latitude,
    required double longitude,
    DateTime? takenAt,
    String? title,
    String? note,
    List<String> tagIds = const [],
  }) async {
    try {
      final id = _uuid.v4();
      final savedPath = await _localDataSource.savePhotoFile(
        sourceImagePath,
        id,
      );
      final now = DateTime.now().toUtc();
      final pin = MemoryPin(
        id: id,
        photoPath: savedPath,
        latitude: latitude,
        longitude: longitude,
        createdAt: now,
        updatedAt: now,
        takenAt: takenAt,
        title: title,
        note: note,
        tagIds: tagIds,
      );
      await _localDataSource.upsert(pin.toCompanion());
      return Right(pin);
    } on StorageException catch (e) {
      return Left(Failure.storage(e.message));
    } catch (e) {
      return Left(Failure.unexpected('Failed to add memory: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMemoryPinLocation({
    required String id,
    required double latitude,
    required double longitude,
  }) {
    return _updatePin(
      id,
      (pin) => pin.copyWith(
        latitude: latitude,
        longitude: longitude,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<Either<Failure, MemoryPin>> updateMemoryPinDetails({
    required String id,
    String? title,
    String? note,
    String? sourceImagePath,
  }) async {
    try {
      final existingRow = await _localDataSource.findById(id);
      if (existingRow == null) {
        return Left(Failure.notFound('Memory $id not found'));
      }
      final current = existingRow.toEntity();

      var photoPath = current.photoPath;
      if (sourceImagePath != null) {
        photoPath = await _localDataSource.savePhotoFile(sourceImagePath, id);
        if (photoPath != current.photoPath) {
          await _localDataSource.deletePhotoFile(current.photoPath);
        }
      }

      final updated = current.copyWith(
        title: title,
        note: note,
        photoPath: photoPath,
        updatedAt: DateTime.now().toUtc(),
        // The old Drive upload no longer matches the photo on disk, so drop
        // it and let the sync engine treat this as a pin needing a fresh
        // upload (it only re-uploads when driveFileId is null).
        driveFileId: sourceImagePath != null ? null : current.driveFileId,
        isSynced: sourceImagePath != null ? false : current.isSynced,
      );
      await _localDataSource.upsert(updated.toCompanion());
      return Right(updated);
    } on StorageException catch (e) {
      return Left(Failure.storage(e.message));
    } catch (e) {
      return Left(Failure.unexpected('Failed to update memory: $e'));
    }
  }

  Future<Either<Failure, Unit>> _updatePin(
    String id,
    MemoryPin Function(MemoryPin current) transform,
  ) async {
    try {
      final existingRow = await _localDataSource.findById(id);
      if (existingRow == null) {
        return Left(Failure.notFound('Memory $id not found'));
      }
      final updated = transform(existingRow.toEntity());
      await _localDataSource.upsert(updated.toCompanion());
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unexpected('Failed to update memory: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMemoryPin(String id) async {
    try {
      final existingRow = await _localDataSource.findById(id);
      await _localDataSource.delete(id);
      if (existingRow != null) {
        await _localDataSource.deletePhotoFile(existingRow.photoPath);
      }
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unexpected('Failed to delete memory: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> savePhotoBytes({
    required List<int> bytes,
    required String pinId,
    required String extension,
  }) async {
    try {
      final path = await _localDataSource.savePhotoBytes(
        bytes,
        pinId,
        extension,
      );
      return Right(path);
    } on StorageException catch (e) {
      return Left(Failure.storage(e.message));
    } catch (e) {
      return Left(Failure.unexpected('Failed to save downloaded photo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markSynced({
    required String id,
    required String driveFileId,
  }) async {
    try {
      final existingRow = await _localDataSource.findById(id);
      if (existingRow == null) {
        return Left(Failure.notFound('Memory $id not found'));
      }
      final updated = existingRow.toEntity().copyWith(
        driveFileId: driveFileId,
        isSynced: true,
      );
      await _localDataSource.upsert(updated.toCompanion());
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unexpected('Failed to mark memory synced: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertSyncedPin(MemoryPin pin) async {
    try {
      await _localDataSource.upsert(pin.copyWith(isSynced: true).toCompanion());
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unexpected('Failed to save synced memory: $e'));
    }
  }
}
