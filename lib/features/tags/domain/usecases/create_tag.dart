import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';
import 'package:memory_compass/features/tags/domain/repositories/tag_repository.dart';

class CreateTagParams {
  const CreateTagParams({required this.name, required this.color});

  final String name;

  /// ARGB color value (see `Color.toARGB32`).
  final int color;
}

class CreateTag implements UseCase<Tag, CreateTagParams> {
  const CreateTag(this._repository);

  final TagRepository _repository;

  @override
  Future<Either<Failure, Tag>> call(CreateTagParams params) =>
      _repository.createTag(name: params.name, color: params.color);
}
