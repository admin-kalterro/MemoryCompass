import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';

class DeleteMemoryPin implements UseCase<Unit, String> {
  const DeleteMemoryPin(this._repository);

  final MemoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteMemoryPin(id);
}
