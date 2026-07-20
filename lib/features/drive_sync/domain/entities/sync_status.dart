import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/drive_account.dart';

part 'sync_status.freezed.dart';

@freezed
sealed class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    DriveAccount? account,
    @Default(false) bool isFolderLinked,
    DateTime? lastSyncedAt,
    @Default(false) bool isSyncing,
    String? lastErrorMessage,
  }) = _SyncStatus;
}

extension SyncStatusX on SyncStatus {
  bool get isSignedIn => account != null;
}
