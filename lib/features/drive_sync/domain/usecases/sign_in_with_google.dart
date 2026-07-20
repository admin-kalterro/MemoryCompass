import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/drive_account.dart';
import 'package:memory_compass/features/drive_sync/domain/repositories/drive_sync_repository.dart';

class SignInWithGoogle implements UseCase<DriveAccount, NoParams> {
  const SignInWithGoogle(this._repository);

  final DriveSyncRepository _repository;

  @override
  Future<Either<Failure, DriveAccount>> call(NoParams params) =>
      _repository.signIn();
}
