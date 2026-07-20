import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

class UpdateMemoryPinDetailsParams {
  const UpdateMemoryPinDetailsParams({
    required this.id,
    this.title,
    this.note,
    this.sourceImagePath,
  });

  final String id;
  final String? title;
  final String? note;

  /// Path to a newly picked photo that should replace the pin's current
  /// one. Left null when the photo isn't being changed.
  final String? sourceImagePath;
}

class UpdateMemoryPinDetails
    implements UseCase<MemoryPin, UpdateMemoryPinDetailsParams> {
  const UpdateMemoryPinDetails(this._repository);

  final MemoryRepository _repository;

  @override
  Future<Either<Failure, MemoryPin>> call(UpdateMemoryPinDetailsParams params) {
    return _repository.updateMemoryPinDetails(
      id: params.id,
      title: params.title,
      note: params.note,
      sourceImagePath: params.sourceImagePath,
    );
  }
}
