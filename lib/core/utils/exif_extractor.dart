import 'dart:typed_data';

import 'package:exif/exif.dart';

/// GPS coordinates and capture time recovered from a photo's EXIF metadata,
/// when present.
class ExtractedPhotoMetadata {
  const ExtractedPhotoMetadata({this.latitude, this.longitude, this.takenAt});

  final double? latitude;
  final double? longitude;
  final DateTime? takenAt;

  bool get hasLocation => latitude != null && longitude != null;
}

/// Reads GPS coordinates and capture date out of a JPEG/HEIC/TIFF's EXIF
/// tags, so a newly-picked photo can default its map pin to where it was
/// actually taken.
class ExifExtractor {
  const ExifExtractor();

  Future<ExtractedPhotoMetadata> extractFromBytes(Uint8List bytes) async {
    final tags = await readExifFromBytes(bytes);
    return extractFromTags(tags);
  }

  /// Pure parsing logic, split out from the byte-reading so it can be unit
  /// tested without real image files.
  ExtractedPhotoMetadata extractFromTags(Map<String, IfdTag> tags) {
    final latitude = _coordinateFromTags(
      valueTag: tags['GPS GPSLatitude'],
      refTag: tags['GPS GPSLatitudeRef'],
      negativeRef: 'S',
    );
    final longitude = _coordinateFromTags(
      valueTag: tags['GPS GPSLongitude'],
      refTag: tags['GPS GPSLongitudeRef'],
      negativeRef: 'W',
    );
    final takenAt = _dateTimeFromTag(
      tags['EXIF DateTimeOriginal'] ?? tags['Image DateTime'],
    );
    return ExtractedPhotoMetadata(
      latitude: latitude,
      longitude: longitude,
      takenAt: takenAt,
    );
  }

  double? _coordinateFromTags({
    required IfdTag? valueTag,
    required IfdTag? refTag,
    required String negativeRef,
  }) {
    final values = valueTag?.values;
    if (values is! IfdRatios || values.ratios.length < 3) return null;

    // Some cameras/phones write GPS ratios with a zero denominator (e.g.
    // when GPS lock wasn't fully acquired at capture time). Ratio.toDouble()
    // turns that into NaN/Infinity, which would otherwise flow straight into
    // a LatLng and crash flutter_map's tile math, so bail out instead.
    if (values.ratios
        .take(3)
        .any((ratio) => ratio.denominator == 0)) {
      return null;
    }

    final degrees = values.ratios[0].toDouble();
    final minutes = values.ratios[1].toDouble();
    final seconds = values.ratios[2].toDouble();
    var decimal = degrees + (minutes / 60) + (seconds / 3600);

    final ref = refTag?.printable.trim().toUpperCase();
    if (ref == negativeRef) decimal = -decimal;
    if (!decimal.isFinite) return null;
    return decimal;
  }

  DateTime? _dateTimeFromTag(IfdTag? tag) {
    final raw = tag?.printable.trim();
    if (raw == null || raw.isEmpty) return null;
    // EXIF datetimes look like "2024:06:21 14:03:11".
    final match = RegExp(
      r'^(\d{4}):(\d{2}):(\d{2})\s+(\d{2}):(\d{2}):(\d{2})',
    ).firstMatch(raw);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }
}
