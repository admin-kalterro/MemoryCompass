import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/core/utils/exif_extractor.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

/// Attempts to read the GPS location embedded in a photo's EXIF data, so
/// the add-memory flow can default the pin location instead of asking the
/// user to place it manually.
class ExtractPhotoLocation implements UseCase<ExtractedPhotoMetadata, String> {
  const ExtractPhotoLocation(this._repository);

  final MemoryRepository _repository;

  @override
  Future<Either<Failure, ExtractedPhotoMetadata>> call(String imagePath) =>
      _repository.readPhotoMetadata(imagePath);
}
