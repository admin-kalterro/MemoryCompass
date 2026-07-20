import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_memory_state.freezed.dart';

@freezed
sealed class AddMemoryState with _$AddMemoryState {
  const factory AddMemoryState({
    String? imagePath,
    double? latitude,
    double? longitude,
    DateTime? takenAt,
    @Default(false) bool locationFromExif,
    String? title,
    String? note,
    @Default(<String>[]) List<String> selectedTagIds,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _AddMemoryState;
}

extension AddMemoryStateX on AddMemoryState {
  bool get hasPhoto => imagePath != null;
  bool get hasLocation => latitude != null && longitude != null;
  bool get canSave => hasPhoto && hasLocation && !isSaving;
}
