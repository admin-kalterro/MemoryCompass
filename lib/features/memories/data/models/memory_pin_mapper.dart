import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memory_compass/core/database/app_database.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';

extension MemoryPinRowMapper on MemoryPinRow {
  MemoryPin toEntity() => MemoryPin(
    id: id,
    photoPath: photoPath,
    latitude: latitude,
    longitude: longitude,
    createdAt: createdAt,
    updatedAt: updatedAt,
    takenAt: takenAt,
    title: title,
    note: note,
    driveFileId: driveFileId,
    isSynced: isSynced,
    tagIds: tagIds == null
        ? const []
        : (jsonDecode(tagIds!) as List).cast<String>(),
  );
}

extension MemoryPinEntityMapper on MemoryPin {
  MemoryPinsCompanion toCompanion() => MemoryPinsCompanion(
    id: Value(id),
    photoPath: Value(photoPath),
    latitude: Value(latitude),
    longitude: Value(longitude),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    takenAt: Value(takenAt),
    title: Value(title),
    note: Value(note),
    driveFileId: Value(driveFileId),
    isSynced: Value(isSynced),
    tagIds: Value(jsonEncode(tagIds)),
  );
}
