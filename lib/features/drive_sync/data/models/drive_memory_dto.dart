import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';

part 'drive_memory_dto.g.dart';

/// One entry of the `manifest.json` file kept in the app's Drive folder.
/// Mirrors [MemoryPin] but points at the Drive file id of the photo instead
/// of a local file path, since paths aren't portable across devices.
@JsonSerializable()
class DriveMemoryDto {
  DriveMemoryDto({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.photoDriveFileId,
    required this.photoExtension,
    this.takenAt,
    this.title,
    this.note,
    this.tagIds = const [],
  });

  final String id;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String photoDriveFileId;

  /// File extension (including the dot) of the original photo, e.g. `.jpg`,
  /// so a downloaded copy keeps the same format.
  final String photoExtension;
  final DateTime? takenAt;
  final String? title;
  final String? note;

  /// [Tag.id] values linked to this pin. Stable across devices because the
  /// matching [DriveTagDto] entries carry the same ids.
  final List<String> tagIds;

  factory DriveMemoryDto.fromJson(Map<String, dynamic> json) =>
      _$DriveMemoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriveMemoryDtoToJson(this);

  factory DriveMemoryDto.fromMemoryPin(MemoryPin pin) {
    assert(
      pin.driveFileId != null,
      'Pin must be uploaded before it is manifested',
    );
    return DriveMemoryDto(
      id: pin.id,
      latitude: pin.latitude,
      longitude: pin.longitude,
      createdAt: pin.createdAt,
      updatedAt: pin.updatedAt,
      photoDriveFileId: pin.driveFileId!,
      photoExtension: p.extension(pin.photoPath).isEmpty
          ? '.jpg'
          : p.extension(pin.photoPath),
      takenAt: pin.takenAt,
      title: pin.title,
      note: pin.note,
      tagIds: pin.tagIds,
    );
  }
}

/// One entry of the tag list kept in `manifest.json`, mirroring [Tag] so tags
/// created on one device show up (and can be linked to pins) on another.
@JsonSerializable()
class DriveTagDto {
  DriveTagDto({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;

  /// ARGB color value (see `Color.toARGB32`).
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DriveTagDto.fromJson(Map<String, dynamic> json) =>
      _$DriveTagDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriveTagDtoToJson(this);

  factory DriveTagDto.fromTag(Tag tag) => DriveTagDto(
    id: tag.id,
    name: tag.name,
    color: tag.color,
    createdAt: tag.createdAt,
    updatedAt: tag.updatedAt,
  );
}

@JsonSerializable()
class DriveManifest {
  DriveManifest({required this.memories, this.tags = const []});

  final List<DriveMemoryDto> memories;
  final List<DriveTagDto> tags;

  factory DriveManifest.fromJson(Map<String, dynamic> json) =>
      _$DriveManifestFromJson(json);

  Map<String, dynamic> toJson() => _$DriveManifestToJson(this);
}
