import 'package:drift/drift.dart';

/// One row per photo pinned on the map.
@DataClassName('MemoryPinRow')
class MemoryPins extends Table {
  TextColumn get id => text()();
  TextColumn get photoPath => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get driveFileId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// JSON-encoded list of [Tags.id] values linked to this pin. Nullable so
  /// existing rows created before tags existed migrate without a backfill.
  TextColumn get tagIds => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A user-defined label that can be linked to any number of memory pins.
@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// ARGB color value (see [Color.toARGB32]).
  IntColumn get color => integer().withDefault(const Constant(0xFF009688))();
  DateTimeColumn get createdAt => dateTime()();

  /// Nullable so rows created before rename/recolor existed migrate without
  /// a backfill; treat null as "same as createdAt" when reading.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row table holding the linked Google Drive folder/manifest state,
/// so the app can find its previously-synced data after a reinstall.
@DataClassName('SyncSettingsRow')
class SyncSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get driveFolderId => text().nullable()();
  TextColumn get manifestFileId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
