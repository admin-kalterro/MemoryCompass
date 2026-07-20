import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:memory_compass/core/database/app_database.dart';
import 'package:memory_compass/core/error/exceptions.dart';

abstract class MemoryLocalDataSource {
  Stream<List<MemoryPinRow>> watchAll();
  Future<List<MemoryPinRow>> getAllOnce();
  Future<MemoryPinRow?> findById(String id);
  Future<void> upsert(MemoryPinsCompanion pin);
  Future<void> delete(String id);

  /// Copies the picked photo into app-private storage so it survives after
  /// the source picked file (e.g. a share-sheet temp file) is gone.
  Future<String> savePhotoFile(String sourceImagePath, String pinId);

  /// Writes downloaded Drive photo bytes into app-private storage.
  Future<String> savePhotoBytes(List<int> bytes, String pinId, String extension);
  Future<void> deletePhotoFile(String photoPath);
}

class MemoryLocalDataSourceImpl implements MemoryLocalDataSource {
  MemoryLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<MemoryPinRow>> watchAll() => _database.watchAllMemoryPins();

  @override
  Future<List<MemoryPinRow>> getAllOnce() => _database.allMemoryPinsOnce();

  @override
  Future<MemoryPinRow?> findById(String id) => _database.findMemoryPin(id);

  @override
  Future<void> upsert(MemoryPinsCompanion pin) =>
      _database.upsertMemoryPin(pin);

  @override
  Future<void> delete(String id) => _database.deleteMemoryPin(id);

  @override
  Future<String> savePhotoFile(String sourceImagePath, String pinId) async {
    try {
      final memoriesDir = await _memoriesDir();
      final extension = p.extension(sourceImagePath);
      // Suffixing with a timestamp keeps this filename distinct from any
      // previous photo saved for this pin (e.g. when editing an existing
      // memory's photo). Flutter's FileImage cache keys purely on the file
      // path, so reusing the old path would keep showing the stale cached
      // image even after the new bytes are written to disk.
      final uniqueName = '$pinId-${DateTime.now().microsecondsSinceEpoch}';
      final destination = File(
        p.join(memoriesDir.path, '$uniqueName$extension'),
      );
      await File(sourceImagePath).copy(destination.path);
      return destination.path;
    } catch (e) {
      throw StorageException('Failed to save photo: $e');
    }
  }

  @override
  Future<String> savePhotoBytes(
    List<int> bytes,
    String pinId,
    String extension,
  ) async {
    try {
      final memoriesDir = await _memoriesDir();
      final destination = File(p.join(memoriesDir.path, '$pinId$extension'));
      await destination.writeAsBytes(bytes, flush: true);
      return destination.path;
    } catch (e) {
      throw StorageException('Failed to save downloaded photo: $e');
    }
  }

  Future<Directory> _memoriesDir() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory(p.join(documentsDir.path, 'memories'));
    if (!await memoriesDir.exists()) {
      await memoriesDir.create(recursive: true);
    }
    return memoriesDir;
  }

  @override
  Future<void> deletePhotoFile(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw StorageException('Failed to delete photo: $e');
    }
  }
}
