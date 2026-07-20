import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:memory_compass/core/di/providers.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/memories/domain/usecases/add_memory_pin.dart';
import 'package:memory_compass/features/memories/presentation/controllers/add_memory_state.dart';
import 'package:memory_compass/features/memories/presentation/providers/memory_providers.dart';

class AddMemoryController extends StateNotifier<AddMemoryState> {
  AddMemoryController(this._ref) : super(const AddMemoryState());

  final Ref _ref;

  /// Opens the gallery picker and, if a photo is chosen, tries to read its
  /// embedded GPS location. Returns false when the user cancels the picker.
  ///
  /// If [initialLocation] is given (the user tapped a spot on the map before
  /// picking a photo), that location is used as-is and the photo's EXIF GPS
  /// data is ignored entirely — only the "Add memory" button flow (no
  /// [initialLocation]) should ever default to a photo's own coordinates.
  Future<bool> pickPhoto({LatLng? initialLocation}) async {
    final picker = _ref.read(imagePickerProvider);
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return false;

    state = AddMemoryState(
      imagePath: picked.path,
      latitude: initialLocation?.latitude,
      longitude: initialLocation?.longitude,
    );

    final result = await _ref
        .read(extractPhotoLocationUseCaseProvider)
        .call(picked.path);
    result.match(
      (failure) {
        // No usable EXIF data: the user will place the pin manually.
      },
      (metadata) {
        state = initialLocation == null
            ? state.copyWith(
                takenAt: metadata.takenAt,
                latitude: metadata.latitude,
                longitude: metadata.longitude,
                locationFromExif: metadata.hasLocation,
              )
            // Keep the tapped location: don't let the photo's own EXIF GPS
            // data override it.
            : state.copyWith(takenAt: metadata.takenAt);
      },
    );
    return true;
  }

  void setLocation(double latitude, double longitude) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      locationFromExif: false,
    );
  }

  void setTitle(String value) => state = state.copyWith(title: value);

  void setNote(String value) => state = state.copyWith(note: value);

  void toggleTag(String tagId) {
    final current = state.selectedTagIds;
    final updated = current.contains(tagId)
        ? current.where((id) => id != tagId).toList()
        : [...current, tagId];
    state = state.copyWith(selectedTagIds: updated);
  }

  Future<bool> save() async {
    if (!state.canSave) {
      state = state.copyWith(
        errorMessage: 'Pick a photo and a location first.',
      );
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);

    final result = await _ref
        .read(addMemoryPinUseCaseProvider)
        .call(
          AddMemoryPinParams(
            sourceImagePath: state.imagePath!,
            latitude: state.latitude!,
            longitude: state.longitude!,
            takenAt: state.takenAt,
            title: _blankToNull(state.title),
            note: _blankToNull(state.note),
            tagIds: state.selectedTagIds,
          ),
        );

    return result.match(
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = const AddMemoryState();
        return true;
      },
    );
  }

  void reset() => state = const AddMemoryState();

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final addMemoryControllerProvider =
    StateNotifierProvider.autoDispose<AddMemoryController, AddMemoryState>(
      (ref) => AddMemoryController(ref),
    );
