import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:memory_compass/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [MemoryPins, Tags, SyncSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tags);
        await m.addColumn(memoryPins, memoryPins.tagIds);
      }
      if (from < 3) {
        await m.addColumn(tags, tags.color);
        await m.addColumn(tags, tags.updatedAt);
      }
    },
  );

  Stream<List<MemoryPinRow>> watchAllMemoryPins() => select(memoryPins).watch();

  Future<MemoryPinRow?> findMemoryPin(String id) =>
      (select(memoryPins)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertMemoryPin(MemoryPinsCompanion pin) =>
      into(memoryPins).insertOnConflictUpdate(pin);

  Future<void> deleteMemoryPin(String id) =>
      (delete(memoryPins)..where((t) => t.id.equals(id))).go();

  Future<List<MemoryPinRow>> allMemoryPinsOnce() => select(memoryPins).get();

  Future<SyncSettingsRow> loadSyncSettings() async {
    final existing = await (select(
      syncSettings,
    )..where((t) => t.id.equals(0))).getSingleOrNull();
    if (existing != null) return existing;
    const defaultRow = SyncSettingsCompanion(id: Value(0));
    await into(syncSettings).insertOnConflictUpdate(defaultRow);
    return (select(syncSettings)..where((t) => t.id.equals(0))).getSingle();
  }

  Future<void> saveSyncSettings(SyncSettingsCompanion settings) => into(
    syncSettings,
  ).insertOnConflictUpdate(settings.copyWith(id: const Value(0)));

  Stream<List<TagRow>> watchAllTags() => select(tags).watch();

  Future<List<TagRow>> allTagsOnce() => select(tags).get();

  Future<void> insertTag(TagsCompanion tag) =>
      into(tags).insertOnConflictUpdate(tag);
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memory_compass.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
