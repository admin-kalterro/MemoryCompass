import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:fpdart/fpdart.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:memory_compass/core/constants/app_constants.dart';
import 'package:memory_compass/core/database/app_database.dart';
import 'package:memory_compass/core/error/exceptions.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/core/utils/mime_type.dart';
import 'package:memory_compass/features/drive_sync/data/datasources/google_auth_datasource.dart';
import 'package:memory_compass/features/drive_sync/data/datasources/google_drive_datasource.dart';
import 'package:memory_compass/features/drive_sync/data/models/drive_memory_dto.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/drive_account.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/sync_status.dart';
import 'package:memory_compass/features/drive_sync/domain/repositories/drive_sync_repository.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/repositories/memory_repository.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';
import 'package:memory_compass/features/tags/domain/repositories/tag_repository.dart';

class DriveSyncRepositoryImpl implements DriveSyncRepository {
  DriveSyncRepositoryImpl({
    required GoogleAuthDataSource authDataSource,
    required GoogleDriveDataSource driveDataSource,
    required AppDatabase database,
    required MemoryRepository memoryRepository,
    required TagRepository tagRepository,
  }) : _authDataSource = authDataSource,
       _driveDataSource = driveDataSource,
       _database = database,
       _memoryRepository = memoryRepository,
       _tagRepository = tagRepository {
    _authDataSource.onAccountChanged.listen((_) => _emitCurrentStatus());
    unawaited(_emitCurrentStatus());
  }

  final GoogleAuthDataSource _authDataSource;
  final GoogleDriveDataSource _driveDataSource;
  final AppDatabase _database;
  final MemoryRepository _memoryRepository;
  final TagRepository _tagRepository;

  final _statusController = StreamController<SyncStatus>.broadcast();
  bool _isSyncing = false;
  String? _lastErrorMessage;

  @override
  Stream<SyncStatus> watchStatus() => _statusController.stream;

  Future<void> _emitCurrentStatus() async {
    final account = _authDataSource.currentAccount;
    final settings = await _database.loadSyncSettings();
    _statusController.add(
      SyncStatus(
        account: account == null
            ? null
            : DriveAccount(
                email: account.email,
                displayName: account.displayName,
                photoUrl: account.photoUrl,
              ),
        isFolderLinked: settings.driveFolderId != null,
        lastSyncedAt: settings.lastSyncedAt,
        isSyncing: _isSyncing,
        lastErrorMessage: _lastErrorMessage,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> restoreSession() async {
    try {
      await _authDataSource.restoreSession();
      await _emitCurrentStatus();
      return const Right(unit);
    } catch (e) {
      return Left(
        Failure.authentication('Could not restore Google session: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, DriveAccount>> signIn() async {
    try {
      final account = await _authDataSource.signIn();
      if (account == null) {
        return const Left(Failure.authentication('Sign-in was cancelled.'));
      }
      await _ensureFolderLinked();
      await _emitCurrentStatus();
      return Right(
        DriveAccount(
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        ),
      );
    } catch (e) {
      return Left(Failure.authentication('Google sign-in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _authDataSource.signOut();
      await _emitCurrentStatus();
      return const Right(unit);
    } catch (e) {
      return Left(Failure.authentication('Sign-out failed: $e'));
    }
  }

  Future<String> _ensureFolderLinked() async {
    final settings = await _database.loadSyncSettings();
    if (settings.driveFolderId != null) return settings.driveFolderId!;

    final client = await _authDataSource.authenticatedClient();
    try {
      final api = drive.DriveApi(client);
      final folderId = await _driveDataSource.findOrCreateFolder(
        api,
        AppConstants.driveFolderName,
      );
      await _database.saveSyncSettings(
        SyncSettingsCompanion(driveFolderId: Value(folderId)),
      );
      return folderId;
    } finally {
      client.close();
    }
  }

  @override
  Future<Either<Failure, Unit>> syncNow() async {
    if (_authDataSource.currentAccount == null) {
      return const Left(
        Failure.authentication('Sign in to Google Drive first.'),
      );
    }

    _isSyncing = true;
    _lastErrorMessage = null;
    await _emitCurrentStatus();

    http.Client? client;
    try {
      client = await _authDataSource.authenticatedClient();
      final api = drive.DriveApi(client);
      final folderId = await _ensureFolderLinked();
      final settings = await _database.loadSyncSettings();

      var manifestFileId = settings.manifestFileId;
      manifestFileId ??= await _driveDataSource.findFileId(
        api,
        folderId: folderId,
        fileName: AppConstants.driveManifestFileName,
      );

      var remoteManifest = DriveManifest(memories: const []);
      if (manifestFileId != null) {
        final bytes = await _driveDataSource.downloadFile(api, manifestFileId);
        remoteManifest = DriveManifest.fromJson(
          jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
        );
      }

      // Merge tags first, by id, since pins reference them by id below.
      // Renames/recolors are reconciled by "most recently updated wins",
      // same as pins below.
      final localTagsResult = await _tagRepository.getAllTagsOnce();
      final localTags = localTagsResult.getOrElse((_) => const <Tag>[]);
      final localTagsById = {for (final tag in localTags) tag.id: tag};

      final mergedTagsById = <String, DriveTagDto>{
        for (final entry in remoteManifest.tags) entry.id: entry,
      };
      for (final tag in localTags) {
        final remoteEntry = mergedTagsById[tag.id];
        if (remoteEntry == null ||
            tag.updatedAt.isAfter(remoteEntry.updatedAt)) {
          mergedTagsById[tag.id] = DriveTagDto.fromTag(tag);
        }
      }

      // Write back any tag that's new or newer on Drive than what's local.
      for (final entry in mergedTagsById.values) {
        final local = localTagsById[entry.id];
        final isUpToDate =
            local != null && !entry.updatedAt.isAfter(local.updatedAt);
        if (isUpToDate) continue;
        await _tagRepository.upsertSyncedTag(
          Tag(
            id: entry.id,
            name: entry.name,
            color: entry.color,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
        );
      }

      final localPinsResult = await _memoryRepository.getAllMemoryPinsOnce();
      final localPins = localPinsResult.getOrElse((_) => const <MemoryPin>[]);

      final mergedById = <String, DriveMemoryDto>{
        for (final entry in remoteManifest.memories) entry.id: entry,
      };
      final localIds = localPins.map((pin) => pin.id).toSet();

      // Push local pins: upload photos that aren't on Drive yet, and push
      // metadata for pins edited more recently than what's on Drive.
      for (final pin in localPins) {
        var current = pin;
        if (current.driveFileId == null) {
          final bytes = await File(current.photoPath).readAsBytes();
          final fileId = await _driveDataSource.uploadOrUpdateFile(
            api,
            folderId: folderId,
            fileName: '${current.id}${p.extension(current.photoPath)}',
            bytes: bytes,
            mimeType: guessImageMimeType(current.photoPath),
          );
          await _memoryRepository.markSynced(
            id: current.id,
            driveFileId: fileId,
          );
          current = current.copyWith(driveFileId: fileId, isSynced: true);
          mergedById[current.id] = DriveMemoryDto.fromMemoryPin(current);
          continue;
        }

        final remoteEntry = mergedById[current.id];
        if (remoteEntry == null ||
            current.updatedAt.isAfter(remoteEntry.updatedAt)) {
          mergedById[current.id] = DriveMemoryDto.fromMemoryPin(current);
        }
      }

      // Pull remote pins that don't exist on this device yet.
      for (final entry in mergedById.values.toList(growable: false)) {
        if (localIds.contains(entry.id)) continue;
        final bytes = await _driveDataSource.downloadFile(
          api,
          entry.photoDriveFileId,
        );
        final savedPathResult = await _memoryRepository.savePhotoBytes(
          bytes: bytes,
          pinId: entry.id,
          extension: entry.photoExtension,
        );
        final photoPath = savedPathResult.getOrElse(
          (failure) => throw StorageException(failure.message),
        );
        await _memoryRepository.upsertSyncedPin(
          MemoryPin(
            id: entry.id,
            photoPath: photoPath,
            latitude: entry.latitude,
            longitude: entry.longitude,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
            takenAt: entry.takenAt,
            title: entry.title,
            note: entry.note,
            driveFileId: entry.photoDriveFileId,
            isSynced: true,
            tagIds: entry.tagIds,
          ),
        );
      }

      final manifestBytes = utf8.encode(
        jsonEncode(
          DriveManifest(
            memories: mergedById.values.toList(),
            tags: mergedTagsById.values.toList(),
          ).toJson(),
        ),
      );
      final newManifestFileId = await _driveDataSource.uploadOrUpdateFile(
        api,
        folderId: folderId,
        fileName: AppConstants.driveManifestFileName,
        bytes: manifestBytes,
        mimeType: 'application/json',
        existingFileId: manifestFileId,
      );

      await _database.saveSyncSettings(
        SyncSettingsCompanion(
          driveFolderId: Value(folderId),
          manifestFileId: Value(newManifestFileId),
          lastSyncedAt: Value(DateTime.now().toUtc()),
        ),
      );

      _isSyncing = false;
      await _emitCurrentStatus();
      return const Right(unit);
    } catch (e) {
      _isSyncing = false;
      _lastErrorMessage = 'Sync failed: $e';
      await _emitCurrentStatus();
      return Left(Failure.drive('Sync failed: $e'));
    } finally {
      client?.close();
    }
  }
}
