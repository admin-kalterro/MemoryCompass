import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

class UpdateMemoryPinDetailsParams {
  const UpdateMemoryPinDetailsParams({
    required this.id,
    this.title,
    this.note,
  });

  final String id;
  final String? title;
  final String? note;
}

class UpdateMemoryPinDetails
    implements UseCase<Unit, UpdateMemoryPinDetailsParams> {
  const UpdateMemoryPinDetails(this._repository);

  final MemoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateMemoryPinDetailsParams params) {
    return _repository.updateMemoryPinDetails(
      id: params.id,
      title: params.title,
      note: params.note,
    );
  }
}
