import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:memory_compass/core/database/app_database.dart';
import 'package:memory_compass/core/utils/exif_extractor.dart';

/// App-wide singletons shared across features. Feature-specific providers
/// live under `features/<feature>/presentation/providers`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final exifExtractorProvider = Provider<ExifExtractor>(
  (ref) => const ExifExtractor(),
);

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
