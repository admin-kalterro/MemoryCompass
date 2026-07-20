import 'package:memory_compass/core/database/app_database.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';

extension TagRowMapper on TagRow {
  Tag toEntity() => Tag(
    id: id,
    name: name,
    color: color,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
  );
}
