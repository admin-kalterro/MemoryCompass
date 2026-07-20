import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/tags/domain/repositories/tag_repository.dart';

class UpdateTagParams {
  const UpdateTagParams({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;

  /// ARGB color value (see `Color.toARGB32`).
  final int color;
}

class UpdateTag implements UseCase<Unit, UpdateTagParams> {
  const UpdateTag(this._repository);

  final TagRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateTagParams params) => _repository
      .updateTag(id: params.id, name: params.name, color: params.color);
}
