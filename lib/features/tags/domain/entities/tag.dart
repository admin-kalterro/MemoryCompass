import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

/// A user-defined label that can be linked to any number of memory pins.
@freezed
sealed class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String name,

    /// ARGB color value (see `Color.toARGB32`).
    required int color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Tag;
}
