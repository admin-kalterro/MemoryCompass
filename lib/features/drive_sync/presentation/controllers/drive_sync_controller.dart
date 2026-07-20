import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/drive_sync/presentation/providers/drive_sync_providers.dart';

/// Orchestrates the Google Drive usecases for the settings screen. The
/// resulting status is read from [syncStatusProvider]; this controller only
/// triggers actions and reports the outcome of the action itself.
class DriveSyncController {
  DriveSyncController(this._ref);

  final Ref _ref;

  Future<Either<Failure, Unit>> restoreSession() {
    return _ref.read(restoreGoogleSessionUseCaseProvider).call(const NoParams());
  }

  /// Signs in and immediately performs a first sync, since reconnecting to
  /// Google Drive is exactly how a user recovers their data on a new phone.
  Future<Either<Failure, Unit>> connectAndSync() async {
    final signInResult = await _ref
        .read(signInWithGoogleUseCaseProvider)
        .call(const NoParams());
    return signInResult.match((failure) async => Left(failure), (_) => syncNow());
  }

  Future<Either<Failure, Unit>> syncNow() {
    return _ref.read(syncNowUseCaseProvider).call(const NoParams());
  }

  Future<Either<Failure, Unit>> disconnect() {
    return _ref.read(signOutOfGoogleUseCaseProvider).call(const NoParams());
  }
}

final driveSyncControllerProvider = Provider<DriveSyncController>(
  (ref) => DriveSyncController(ref),
);
