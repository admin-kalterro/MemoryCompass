import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/utils/exif_extractor.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';

abstract class MemoryRepository {
  /// Live view of every pin, ordered by however the local store returns
  /// them; used to drive the map markers.
  Stream<List<MemoryPin>> watchAllMemoryPins();

  Future<Either<Failure, List<MemoryPin>>> getAllMemoryPinsOnce();

  /// Reads EXIF GPS/capture-time metadata from the picked photo, if any.
  Future<Either<Failure, ExtractedPhotoMetadata>> readPhotoMetadata(
    String imagePath,
  );

  /// Copies [sourceImagePath] into app storage and records a new pin.
  Future<Either<Failure, MemoryPin>> addMemoryPin({
    required String sourceImagePath,
    required double latitude,
    required double longitude,
    DateTime? takenAt,
    String? title,
    String? note,
    List<String> tagIds = const [],
  });

  Future<Either<Failure, Unit>> updateMemoryPinLocation({
    required String id,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, Unit>> updateMemoryPinDetails({
    required String id,
    String? title,
    String? note,
  });

  Future<Either<Failure, Unit>> deleteMemoryPin(String id);

  /// Persists photo bytes downloaded from Drive into app storage, returning
  /// the local file path. Used by the sync engine to materialize pins that
  /// exist remotely but not yet on this device.
  Future<Either<Failure, String>> savePhotoBytes({
    required List<int> bytes,
    required String pinId,
    required String extension,
  });

  /// Records that a pin now has a corresponding file in Drive.
  Future<Either<Failure, Unit>> markSynced({
    required String id,
    required String driveFileId,
  });

  /// Inserts or overwrites a pin with data reconciled from Drive.
  Future<Either<Failure, Unit>> upsertSyncedPin(MemoryPin pin);
}
