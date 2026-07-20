import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';

/// A single unit of application business logic.
///
/// [Type] is the successful return type, [Params] is the input the use
/// case needs. Use [NoParams] when a use case takes no arguments.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
