// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_memory_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriveMemoryDto _$DriveMemoryDtoFromJson(Map<String, dynamic> json) =>
    DriveMemoryDto(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      photoDriveFileId: json['photoDriveFileId'] as String,
      photoExtension: json['photoExtension'] as String,
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      title: json['title'] as String?,
      note: json['note'] as String?,
      tagIds:
          (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DriveMemoryDtoToJson(DriveMemoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'photoDriveFileId': instance.photoDriveFileId,
      'photoExtension': instance.photoExtension,
      'takenAt': instance.takenAt?.toIso8601String(),
      'title': instance.title,
      'note': instance.note,
      'tagIds': instance.tagIds,
    };

DriveTagDto _$DriveTagDtoFromJson(Map<String, dynamic> json) => DriveTagDto(
  id: json['id'] as String,
  name: json['name'] as String,
  color: (json['color'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DriveTagDtoToJson(DriveTagDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

DriveManifest _$DriveManifestFromJson(Map<String, dynamic> json) =>
    DriveManifest(
      memories: (json['memories'] as List<dynamic>)
          .map((e) => DriveMemoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => DriveTagDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DriveManifestToJson(DriveManifest instance) =>
    <String, dynamic>{'memories': instance.memories, 'tags': instance.tags};
