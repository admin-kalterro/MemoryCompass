import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

class UpdateMemoryPinLocationParams {
  const UpdateMemoryPinLocationParams({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final double latitude;
  final double longitude;
}

class UpdateMemoryPinLocation
    implements UseCase<Unit, UpdateMemoryPinLocationParams> {
  const UpdateMemoryPinLocation(this._repository);

  final MemoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateMemoryPinLocationParams params) {
    return _repository.updateMemoryPinLocation(
      id: params.id,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
