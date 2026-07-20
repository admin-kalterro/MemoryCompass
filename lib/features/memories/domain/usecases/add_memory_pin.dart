import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

class AddMemoryPinParams {
  const AddMemoryPinParams({
    required this.sourceImagePath,
    required this.latitude,
    required this.longitude,
    this.takenAt,
    this.title,
    this.note,
    this.tagIds = const [],
  });

  final String sourceImagePath;
  final double latitude;
  final double longitude;
  final DateTime? takenAt;
  final String? title;
  final String? note;
  final List<String> tagIds;
}

class AddMemoryPin implements UseCase<MemoryPin, AddMemoryPinParams> {
  const AddMemoryPin(this._repository);

  final MemoryRepository _repository;

  @override
  Future<Either<Failure, MemoryPin>> call(AddMemoryPinParams params) {
    return _repository.addMemoryPin(
      sourceImagePath: params.sourceImagePath,
      latitude: params.latitude,
      longitude: params.longitude,
      takenAt: params.takenAt,
      title: params.title,
      note: params.note,
      tagIds: params.tagIds,
    );
  }
}
