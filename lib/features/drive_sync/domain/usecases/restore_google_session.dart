import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/drive_sync/domain/repositories/drive_sync_repository.dart';

class RestoreGoogleSession implements UseCase<Unit, NoParams> {
  const RestoreGoogleSession(this._repository);

  final DriveSyncRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.restoreSession();
}
