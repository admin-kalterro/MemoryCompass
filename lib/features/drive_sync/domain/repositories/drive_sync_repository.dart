import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/drive_account.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/sync_status.dart';

abstract class DriveSyncRepository {
  /// Live account/link/sync status, driving the settings screen.
  Stream<SyncStatus> watchStatus();

  /// Silently restores a previous Google session on app startup, if any.
  Future<Either<Failure, Unit>> restoreSession();

  /// Interactive Google sign-in, requesting Drive access limited to files
  /// this app creates (`drive.file` scope).
  Future<Either<Failure, DriveAccount>> signIn();

  Future<Either<Failure, Unit>> signOut();

  /// Reconciles local memories with the linked Drive folder: uploads new
  /// local pins, downloads pins created on another device, and pushes the
  /// merged manifest back to Drive.
  Future<Either<Failure, Unit>> syncNow();
}
