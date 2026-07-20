import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_pin.freezed.dart';

/// A single photo pinned at a location on the map.
@freezed
sealed class MemoryPin with _$MemoryPin {
  const factory MemoryPin({
    required String id,
    required String photoPath,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? takenAt,
    String? title,
    String? note,
    String? driveFileId,
    @Default(false) bool isSynced,
    @Default(<String>[]) List<String> tagIds,
  }) = _MemoryPin;
}
