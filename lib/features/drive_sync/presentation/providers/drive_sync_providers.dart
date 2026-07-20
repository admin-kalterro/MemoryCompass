import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_compass/core/di/providers.dart';
import 'package:memory_compass/features/drive_sync/data/datasources/google_auth_datasource.dart';
import 'package:memory_compass/features/drive_sync/data/datasources/google_drive_datasource.dart';
import 'package:memory_compass/features/drive_sync/data/repositories/drive_sync_repository_impl.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/sync_status.dart';
import 'package:memory_compass/features/drive_sync/domain/repositories/drive_sync_repository.dart';
import 'package:memory_compass/features/drive_sync/domain/usecases/restore_google_session.dart';
import 'package:memory_compass/features/drive_sync/domain/usecases/sign_in_with_google.dart';
import 'package:memory_compass/features/drive_sync/domain/usecases/sign_out_of_google.dart';
import 'package:memory_compass/features/drive_sync/domain/usecases/sync_now.dart';
import 'package:memory_compass/features/memories/presentation/providers/memory_providers.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';

final googleAuthDataSourceProvider = Provider<GoogleAuthDataSource>(
  (ref) => GoogleAuthDataSource(),
);

final googleDriveDataSourceProvider = Provider<GoogleDriveDataSource>(
  (ref) => const GoogleDriveDataSource(),
);

/// Kept alive for the app's lifetime: it owns the broadcast status stream
/// and the Google Sign-In session, both of which must survive navigation.
final driveSyncRepositoryProvider = Provider<DriveSyncRepository>((ref) {
  return DriveSyncRepositoryImpl(
    authDataSource: ref.watch(googleAuthDataSourceProvider),
    driveDataSource: ref.watch(googleDriveDataSourceProvider),
    database: ref.watch(appDatabaseProvider),
    memoryRepository: ref.watch(memoryRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
  );
});

final restoreGoogleSessionUseCaseProvider = Provider(
  (ref) => RestoreGoogleSession(ref.watch(driveSyncRepositoryProvider)),
);

final signInWithGoogleUseCaseProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(driveSyncRepositoryProvider)),
);

final signOutOfGoogleUseCaseProvider = Provider(
  (ref) => SignOutOfGoogle(ref.watch(driveSyncRepositoryProvider)),
);

final syncNowUseCaseProvider = Provider(
  (ref) => SyncNow(ref.watch(driveSyncRepositoryProvider)),
);

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(driveSyncRepositoryProvider).watchStatus();
});
